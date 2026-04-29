/**
 * Expense Management Routes
 * Handles creation, retrieval, updates, and deletion of expense records and vouchers.
 */

const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createNotification } = require('../utils/notifications');
const { expenseUpload } = require('../config/multer');
const { sendEmail } = require('../utils/mailer');
const path = require('path');
const fs = require('fs');
const { getIO } = require('../utils/socket');

/**
 * POST /api/expenses/
 * Create a new expense record with optional voucher uploads.
 * Role: All Users
 */
router.post('/', authenticateToken, authorizeRoles('MANAGER', 'USER'), expenseUpload.array('vouchers', 10), async (req, res) => {
  try {
    const { title, category, department, amount, expense_date, description } = req.body;
    const userId = req.user.id;
    const role = req.user.role;

    if (!title || !category || !amount || !expense_date) {
      return res.status(400).json({ message: 'Title, category, amount, and date are required' });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'At least one voucher/document is required' });
    }

    // Insert expense
    const [expenseResult] = await db.execute(
      `INSERT INTO expenses (user_id, title, category, department, amount, expense_date, description, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [userId, title, category, department || null, amount, expense_date, description, 'CREATED']
    );

    const expenseId = expenseResult.insertId;

    // Auto-approve if CEO, otherwise set to PENDING_APPROVAL
    let status = 'CREATED';
    if (role === 'CEO') {
      status = 'RECEIPT_APPROVED';
      await db.execute(
        'UPDATE expenses SET status = ?, approved_by = ?, approved_at = NOW() WHERE id = ?',
        [status, userId, expenseId]
      );
    } else {
      status = 'PENDING_APPROVAL';
      await db.execute(
        'UPDATE expenses SET status = ? WHERE id = ?',
        [status, expenseId]
      );
    }

    // Save document information
    const documentPromises = req.files.map(file => {
      return db.execute(
        `INSERT INTO expense_documents (expense_id, document_path, original_filename, file_type, file_size) 
         VALUES (?, ?, ?, ?, ?)`,
        [
          expenseId,
          file.path,
          file.originalname,
          file.mimetype,
          file.size || 0 // Cloudinary might not return size
        ]
      );
    });

    await Promise.all(documentPromises);

    // Notify appropriate person for approval
    if (role === 'USER') {
      // Notify manager
      const [mgrRows] = await db.execute('SELECT manager_id, full_name FROM users WHERE id = ?', [userId]);
      if (mgrRows[0] && mgrRows[0].manager_id) {
        const [managerRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [mgrRows[0].manager_id]);
        const manager = managerRows[0];

        await createNotification(
          mgrRows[0].manager_id,
          'EXPENSE_PENDING',
          'New Expense for Approval',
          `${mgrRows[0].full_name} has submitted an expense "${title}" for Rs. ${amount}.`,
          expenseId
        );

        if (manager && manager.email) {
          await sendEmail(
            manager.email,
            'New Expense Pending Your Approval',
            `Dear ${manager.full_name},\n\nA new expense "${title}" for Rs. ${amount} has been submitted by ${mgrRows[0].full_name} and is awaiting your approval.\n\nBest regards,\nOffice Expense Management System`
          );
        }
      }
    } else if (role === 'MANAGER') {
      // Notify CEO
      const [ceos] = await db.execute('SELECT id, email, full_name FROM users WHERE role = "CEO"');
      const [managerRow] = await db.execute('SELECT full_name FROM users WHERE id = ?', [userId]);
      for (const ceo of ceos) {
        await createNotification(
          ceo.id,
          'EXPENSE_PENDING',
          'New Manager Expense',
          `${managerRow[0].full_name} has submitted an expense "${title}" for Rs. ${amount}.`,
          expenseId
        );

        if (ceo.email) {
          await sendEmail(
            ceo.email,
            'New Expense Pending Approval',
            `Dear ${ceo.full_name},\n\nA manager ${managerRow[0].full_name} has submitted an expense "${title}" for Rs. ${amount} and is awaiting your approval.\n\nBest regards,\nOffice Expense Management System`
          );
        }
      }
    }

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${userId}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    res.status(201).json({
      message: 'Expense created successfully',
      expenseId,
      status
    });
  } catch (error) {
    console.error('Create expense error:', error);
    res.status(500).json({ message: 'Server error creating expense' });
  }
});

// Get expenses (filtered by role)
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { status, category, start_date, end_date, user_id } = req.query;
    const role = req.user.role;
    const userId = req.user.id;

    let query = `
      SELECT e.*, u.full_name, u.email, u.role as user_role, u.manager_id,
             (SELECT COUNT(*) FROM expense_documents WHERE expense_id = e.id) as document_count,
             (SELECT document_path FROM expense_documents WHERE expense_id = e.id LIMIT 1) as document_path,
             au.full_name as approved_by_name,
             au.role as approved_by_role
      FROM expenses e
      JOIN users u ON e.user_id = u.id
      LEFT JOIN users au ON e.approved_by = au.id
      WHERE 1=1
    `;
    const params = [];

    // Role-based filtering
    if (role === 'USER') {
      query += ' AND e.user_id = ?';
      params.push(userId);
    } else if (role === 'MANAGER') {
      // Managers see expenses from users assigned to them
      query += ' AND (e.user_id = ? OR (u.role = ? AND u.manager_id = ?))';
      params.push(userId, 'USER', userId);
    }
    // CEO sees all expenses

    if (status) {
      query += ' AND e.status = ?';
      params.push(status);
    }

    if (category) {
      query += ' AND e.category = ?';
      params.push(category);
    }

    if (start_date) {
      query += ' AND e.expense_date >= ?';
      params.push(start_date);
    }

    if (end_date) {
      query += ' AND e.expense_date <= ?';
      params.push(end_date);
    }

    if (user_id && (role === 'CEO' || role === 'MANAGER')) {
      query += ' AND e.user_id = ?';
      params.push(user_id);
    }

    query += ' ORDER BY e.created_at DESC';

    const [expenses] = await db.execute(query, params);

    // Normalize document paths
    const normalizedExpenses = expenses.map(expense => {
      if (expense.document_path) {
        if (!expense.document_path.startsWith('http://') && !expense.document_path.startsWith('https://')) {
          // Find 'uploads' directory in the path and keep everything after it
          const uploadsIndex = expense.document_path.indexOf('uploads');
          if (uploadsIndex !== -1) {
            // Normalize slashes to forward slashes for URL
            expense.document_path = expense.document_path.substring(uploadsIndex).replace(/\\/g, '/');
          }
        }
      }
      return expense;
    });

    res.json({ expenses: normalizedExpenses });
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get single expense with documents
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const role = req.user.role;
    const userId = req.user.id;

    const [expenses] = await db.execute(
      `SELECT e.*, u.full_name, u.email, u.role as user_role
       FROM expenses e
       JOIN users u ON e.user_id = u.id
       WHERE e.id = ?`,
      [id]
    );

    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    const expense = expenses[0];

    // Authorization check
    if (role === 'USER' && expense.user_id !== userId) {
      return res.status(403).json({ message: 'Access denied' });
    }

    if (role === 'MANAGER' && expense.user_role !== 'USER' && expense.user_id !== userId) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Get documents
    const [documents] = await db.execute(
      'SELECT id, document_path, original_filename, file_type, file_size, uploaded_at FROM expense_documents WHERE expense_id = ?',
      [id]
    );

    res.json({ expense, documents });
  } catch (error) {
    console.error('Get expense error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update expense
router.put('/:id', authenticateToken, expenseUpload.array('vouchers', 10), async (req, res) => {
  try {
    const { id } = req.params;
    const { title, category, department, amount, expense_date, description } = req.body;
    const userId = req.user.id;

    // Check if expense exists and belongs to user
    const [expenses] = await db.execute('SELECT * FROM expenses WHERE id = ? AND user_id = ?', [id, userId]);
    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found or unauthorized' });
    }

    const expense = expenses[0];
    if (expense.status !== 'CREATED' && expense.status !== 'PENDING_APPROVAL' && expense.status !== 'RECEIPT_APPROVED' && expense.status !== 'REJECTED') {
      return res.status(400).json({ message: 'Cannot edit expense that is already processed further' });
    }

    // If expense was rejected, reset status to PENDING_APPROVAL on edit so it can be re-reviewed
    let newStatus = expense.status;
    let rejectionReason = expense.rejection_reason;
    if (expense.status === 'REJECTED') {
      newStatus = 'PENDING_APPROVAL';
      rejectionReason = null;
    }

    // Update expense fields
    await db.execute(
      `UPDATE expenses SET title = ?, category = ?, department = ?, amount = ?, expense_date = ?, description = ?, status = ?, rejection_reason = ? WHERE id = ?`,
      [title || expense.title, category || expense.category, department || expense.department || null, amount || expense.amount, expense_date || expense.expense_date, description || expense.description, newStatus, rejectionReason, id]
    );

    // Handle new files if any
    if (req.files && req.files.length > 0) {
      const documentPromises = req.files.map(file => {
        return db.execute(
          `INSERT INTO expense_documents (expense_id, document_path, original_filename, file_type, file_size) 
           VALUES (?, ?, ?, ?, ?)`,
          [id, file.path, file.originalname, file.mimetype, file.size || 0]
        );
      });
      await Promise.all(documentPromises);
    }

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${userId}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    res.json({ message: 'Expense updated successfully' });
  } catch (error) {
    console.error('Update expense error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete expense
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if expense exists and belongs to user
    const [expenses] = await db.execute('SELECT * FROM expenses WHERE id = ? AND user_id = ?', [id, userId]);
    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found or unauthorized' });
    }

    const expense = expenses[0];
    if (expense.status !== 'CREATED' && expense.status !== 'PENDING_APPROVAL' && expense.status !== 'RECEIPT_APPROVED' && expense.status !== 'REJECTED') {
      return res.status(400).json({ message: 'Cannot delete expense that is already processed further' });
    }

    // Delete documents first (optional: delete actual files from disk too)
    await db.execute('DELETE FROM expense_documents WHERE expense_id = ?', [id]);

    await db.execute('DELETE FROM expenses WHERE id = ?', [id]);
    
    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${userId}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }
    
    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    console.error('Delete expense error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Approve expense (Manager for User expenses, CEO for all)
router.put('/:id/approve', authenticateToken, authorizeRoles('CEO', 'MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const approverId = req.user.id;
    const role = req.user.role;

    // Get expense details
    const [expenses] = await db.execute(
      `SELECT e.*, u.role as user_role FROM expenses e 
       JOIN users u ON e.user_id = u.id 
       WHERE e.id = ?`,
      [id]
    );

    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    const expense = expenses[0];

    // Authorization: Manager can only approve USER expenses
    if (role === 'MANAGER' && expense.user_role !== 'USER') {
      return res.status(403).json({ message: 'Managers can only approve user expenses' });
    }

    if (expense.status !== 'PENDING_APPROVAL') {
      return res.status(400).json({ message: 'Expense is not in pending approval status' });
    }

    await db.execute(
      'UPDATE expenses SET status = ?, approved_by = ?, approved_at = NOW() WHERE id = ?',
      ['RECEIPT_APPROVED', approverId, id]
    );

    res.json({ message: 'Expense approved successfully' });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${expense.user_id}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    // Notify user
    await createNotification(
      expense.user_id,
      'EXPENSE_APPROVED',
      'Expense Approved',
      `Your expense "${expense.title}" for Rs. ${expense.amount} has been approved.`,
      id
    );

    // Fetch user email
    const [userRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [expense.user_id]);
    const userEmail = userRows[0]?.email;
    const userFullName = userRows[0]?.full_name;

    if (userEmail) {
      await sendEmail(
        userEmail,
        'Expense Approved',
        `Dear ${userFullName},\n\nYour expense "${expense.title}" for Rs. ${expense.amount} has been approved.\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Approve expense error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reject expense
router.put('/:id/reject', authenticateToken, authorizeRoles('CEO', 'MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const { rejection_reason } = req.body;
    const role = req.user.role;

    // Get expense details
    const [expenses] = await db.execute(
      `SELECT e.*, u.role as user_role FROM expenses e 
       JOIN users u ON e.user_id = u.id 
       WHERE e.id = ?`,
      [id]
    );

    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    const expense = expenses[0];

    // Authorization: Manager can only reject USER expenses
    if (role === 'MANAGER' && expense.user_role !== 'USER') {
      return res.status(403).json({ message: 'Managers can only reject user expenses' });
    }

    await db.execute(
      'UPDATE expenses SET status = ?, rejection_reason = ? WHERE id = ?',
      ['REJECTED', rejection_reason || 'No reason provided', id]
    );

    res.json({ message: 'Expense rejected successfully' });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${expense.user_id}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    // Notify user
    await createNotification(
      expense.user_id,
      'EXPENSE_REJECTED',
      'Expense Rejected',
      `Your expense "${expense.title}" for Rs. ${expense.amount} has been rejected. Reason: ${rejection_reason || 'No reason provided'}`,
      id
    );

    // Fetch user email
    const [userRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [expense.user_id]);
    const user = userRows[0];

    if (user && user.email) {
      await sendEmail(
        user.email,
        'Expense Rejected',
        `Dear ${user.full_name},\n\nYour expense "${expense.title}" for Rs. ${expense.amount} has been rejected.\n\nReason: ${rejection_reason || 'No reason provided'}\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Reject expense error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update expense status explicitly (for allocation flow)
router.put('/:id/status', authenticateToken, authorizeRoles('CEO', 'MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Only allow specific transitions if needed, or generally allow for CEO
    // For now, allow CEO to set FUND_ALLOCATED

    await db.execute(
      'UPDATE expenses SET status = ? WHERE id = ?',
      [status, id]
    );

    // Broadcast via Socket.io
    try {
      // Get user ID to notify them specifically
      const [rows] = await db.execute('SELECT user_id FROM expenses WHERE id = ?', [id]);
      const expenseUserId = rows[0]?.user_id;

      const io = getIO();
      if (expenseUserId) io.to(`user_${expenseUserId}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    res.json({ message: 'Expense status updated successfully' });
  } catch (error) {
    console.error('Update expense status error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Download voucher/document
router.get('/:id/documents/:docId', authenticateToken, async (req, res) => {
  try {
    const { id, docId } = req.params;
    const role = req.user.role;
    const userId = req.user.id;

    // Get expense to check authorization
    const [expenses] = await db.execute(
      'SELECT user_id FROM expenses WHERE id = ?',
      [id]
    );

    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found' });
    }

    const expense = expenses[0];

    // Authorization check
    if (role === 'USER' && expense.user_id !== userId) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Get document
    const [documents] = await db.execute(
      'SELECT document_path, original_filename, file_type FROM expense_documents WHERE id = ? AND expense_id = ?',
      [docId, id]
    );

    if (documents.length === 0) {
      return res.status(404).json({ message: 'Document not found' });
    }

    const doc = documents[0];
    
    // If it's a Cloudinary URL, simply redirect the user to it
    if (doc.document_path.startsWith('http://') || doc.document_path.startsWith('https://')) {
      return res.redirect(doc.document_path);
    }

    const filePath = path.join(__dirname, '..', doc.document_path);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ message: 'File not found on server' });
    }

    res.setHeader('Content-Type', doc.file_type);
    res.setHeader('Content-Disposition', `attachment; filename="${doc.original_filename}"`);
    res.sendFile(path.resolve(filePath));
  } catch (error) {
    console.error('Download document error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete specific document from expense
router.delete('/:id/documents/:docId', authenticateToken, async (req, res) => {
  try {
    const { id, docId } = req.params;
    const role = req.user.role;
    const userId = req.user.id;

    // Check expense ownership/permission
    const [expenses] = await db.execute('SELECT * FROM expenses WHERE id = ?', [id]);
    if (expenses.length === 0) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    const expense = expenses[0];

    // Authorization: User can delete own, Manager can delete own (and maybe team's if editing allowed? adhering to edit rules)
    // Generally only the creator matches user_id.
    if (expense.user_id !== userId && role !== 'CEO') {
      // If manager editing team expense? current logic restricts editing to own expenses mostly, 
      // except possibly for approval flow but editing usually implies creator.
      // Let's stick to user_id check or CEO. 
      // If Manager is editing a User's expense (functionality not fully explicit but assuming restricted to own for now unless CEO specific)
      // Actually earlier code: `if (expense.user_id !== userId) return 403` for update.
      // So we stick to that.
      if (role === 'MANAGER' && expense.user_id !== userId) {
        // Check if manager is allowed to edit team expenses? 
        // The update route says: `SELECT * FROM expenses WHERE id = ? AND user_id = ?` => only own expenses.
        return res.status(403).json({ message: 'Access denied' });
      }
      if (role === 'USER' && expense.user_id !== userId) {
        return res.status(403).json({ message: 'Access denied' });
      }
    }

    if (expense.status !== 'CREATED' && expense.status !== 'PENDING_APPROVAL' && expense.status !== 'RECEIPT_APPROVED' && expense.status !== 'REJECTED') {
      return res.status(400).json({ message: 'Cannot delete files from approved/processed expenses' });
    }

    // Get document path to delete file
    const [documents] = await db.execute('SELECT document_path FROM expense_documents WHERE id = ? AND expense_id = ?', [docId, id]);
    if (documents.length === 0) {
      return res.status(404).json({ message: 'Document not found' });
    }
    const docPath = documents[0].document_path;

    // Delete from DB
    await db.execute('DELETE FROM expense_documents WHERE id = ?', [docId]);

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${userId}`).emit('expenseUpdated');
      io.to('role_CEO').emit('expenseUpdated');
      io.to('role_MANAGER').emit('expenseUpdated');
    } catch (err) { }

    // Delete from filesystem if it's a local file
    if (!docPath.startsWith('http://') && !docPath.startsWith('https://')) {
      const fullPath = path.join(__dirname, '..', docPath);
      if (fs.existsSync(fullPath)) {
        try {
          fs.unlinkSync(fullPath);
        } catch (err) {
          console.error('Failed to delete file from disk:', err);
          // Continue even if disk delete fails
        }
      }
    } else {
      // Cloudinary deletion can be implemented here in the future
      // For now, DB deletion is sufficient to remove access
      console.log('Skipping physical deletion of Cloudinary file:', docPath);
    }

    res.json({ message: 'Document deleted successfully' });
  } catch (error) {
    console.error('Delete document error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
