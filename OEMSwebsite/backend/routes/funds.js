const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createNotification } = require('../utils/notifications');
const { sendEmail } = require('../utils/mailer');
const { getIO } = require('../utils/socket');

// Allocate operational fund (CEO to Manager, Manager to User)
const { chequeUpload } = require('../config/multer');

router.post('/operational', authenticateToken, authorizeRoles('CEO', 'MANAGER'), chequeUpload.single('cheque_image'), async (req, res) => {
  try {
    const {
      to_user_id,
      amount,
      description,
      payment_mode,
      cheque_number,
      bank_name,
      cheque_date,
      account_holder_name,
      upi_id,
      transaction_id
    } = req.body;

    // Check if file was uploaded or existing path provided
    let cheque_image_path = req.file ? req.file.path.replace(/\\/g, '/').split('uploads/')[1] ? 'uploads/' + req.file.path.replace(/\\/g, '/').split('uploads/')[1] : req.file.path : null;

    // If no new file, check for existing path
    if (!cheque_image_path && req.body.existing_cheque_image_path) {
      cheque_image_path = req.body.existing_cheque_image_path;
    }

    console.log('Operational Fund Allocation Request Body:', req.body); // DEBUG LOG
    const fromUserId = req.user.id;
    const role = req.user.role;

    if (!to_user_id || !amount) {
      if (req.file) {
        // Clean up uploaded file if validation fails
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ message: 'Recipient user ID and amount are required' });
    }

    // Validate payment mode (optional but good practice)
    if (payment_mode && !['CASH', 'CHEQUE', 'UPI'].includes(payment_mode)) {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ message: 'Invalid payment mode' });
    }

    if (payment_mode === 'CHEQUE') {
      if (!cheque_number || !bank_name || !cheque_date || !account_holder_name) {
        if (req.file) {
          const fs = require('fs');
          if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
        }
        return res.status(400).json({ message: 'Missing required Cheque details' });
      }
    }

    if (payment_mode === 'UPI') {
      if (!upi_id || !transaction_id) {
        // Transaction ID is crucial for UPI verification
        return res.status(400).json({ message: 'UPI ID and Transaction ID are required' });
      }
    }

    // Verify recipient exists and get role
    const [recipients] = await db.execute(
      'SELECT id, role, status FROM users WHERE id = ?',
      [to_user_id]
    );

    if (recipients.length === 0) {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(404).json({ message: 'Recipient user not found' });
    }

    const recipient = recipients[0];

    if (recipient.status !== 'APPROVED') {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ message: 'Recipient user is not approved' });
    }

    // Authorization: CEO can allocate to Manager, Manager can allocate to User
    if (role === 'CEO' && recipient.role !== 'MANAGER') {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(403).json({ message: 'CEO can only allocate funds to Managers' });
    }

    if (role === 'MANAGER' && recipient.role !== 'USER') {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(403).json({ message: 'Managers can only allocate funds to Users' });
    }

    if (fromUserId === to_user_id) {
      if (req.file) {
        const fs = require('fs');
        if(!req.file.path.startsWith('http')) fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ message: 'Cannot allocate funds to yourself' });
    }

    // Create fund allocation
    const [result] = await db.execute(
      `INSERT INTO operational_funds (
        from_user_id, 
        to_user_id, 
        amount, 
        description, 
        payment_mode, 
        cheque_number,
        bank_name,
        cheque_date,
        account_holder_name,
        cheque_image_path,
        upi_id,
        transaction_id,
        expansion_id,
        status
       ) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        fromUserId,
        to_user_id,
        parseFloat(amount),
        description || null,
        payment_mode || null,
        cheque_number || null,
        bank_name || null,
        cheque_date || null,
        account_holder_name || null,
        cheque_image_path || null,
        upi_id || null,
        transaction_id || null,
        req.body.expansion_id || null,
        'ALLOCATED'
      ]
    );

    // Update allocated_at timestamp
    await db.execute(
      'UPDATE operational_funds SET allocated_at = NOW() WHERE id = ?',
      [result.insertId]
    );

    // If this allocation is for an expansion request, update its status
    if (req.body.expansion_id) {
      await db.execute(
        'UPDATE expansion_funds SET status = "ALLOCATED" WHERE id = ?',
        [req.body.expansion_id]
      );
    }

    // Handle linked expense status update
    let expenseId = req.body.expense_id;
    
    // Fallback to description parsing if expenseId not explicitly provided
    if (!expenseId && description) {
      const match = description.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
      if (match) expenseId = match[1];
    }

    if (expenseId) {
      // Only set as FUND_ALLOCATED if the final user is receiving it
      if (recipient.role === 'USER') {
        await db.execute(
          'UPDATE expenses SET status = ? WHERE id = ?',
          ['FUND_ALLOCATED', expenseId]
        );
      } else if (recipient.role === 'MANAGER') {
        // If Manager receives it, it's just intermediate step
        await db.execute(
          'UPDATE expenses SET status = ? WHERE id = ?',
          ['EXPANSION_ALLOCATED', expenseId]
        );
      }
    }

    // Notify recipient
    const [sender] = await db.execute('SELECT full_name FROM users WHERE id = ?', [fromUserId]);
    const [recipientRow] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [to_user_id]);
    const recipientUser = recipientRow[0];

    await createNotification(
      to_user_id,
      'FUND_ALLOCATED',
      'New Fund Allocation',
      `${sender[0].full_name} has allocated Rs. ${amount} to your account.`,
      result.insertId
    );

    if (recipientUser && recipientUser.email) {
      await sendEmail(
        recipientUser.email,
        'New Fund Allocation Received',
        `Dear ${recipientUser.full_name},\n\n${sender[0].full_name} has allocated Rs. ${amount} to your account.\n\nDescription: ${description || 'No description provided'}\n\nBest regards,\nOffice Expense Management System`
      );
    }

    // Broadcast via Socket.io
    try {
      const io = getIO();
      // Notify both parties
      io.to(`user_${fromUserId}`).emit('fundUpdated');
      io.to(`user_${to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
      
      // If an expense status was updated, notify all relevant parties
      if (expenseId) {
        io.to(`user_${recipient.id}`).emit('expenseUpdated'); // Recipient user
        io.to(`user_${fromUserId}`).emit('expenseUpdated'); // Manager
        io.to('role_CEO').emit('expenseUpdated');
        io.to('role_MANAGER').emit('expenseUpdated');
      }
    } catch (err) { }

    res.status(201).json({
      message: 'Fund allocated successfully',
      fundId: result.insertId
    });
  } catch (error) {
    console.error('Allocate fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Request operational fund (User to Manager)
router.post('/request', authenticateToken, authorizeRoles('USER'), async (req, res) => {
  try {
    const { manager_id, amount, description } = req.body;
    const userId = req.user.id;

    if (!manager_id || !amount) {
      return res.status(400).json({ message: 'Manager ID and amount are required' });
    }

    // Verify manager exists
    const [managers] = await db.execute(
      'SELECT id, role FROM users WHERE id = ? AND role = "MANAGER"',
      [manager_id]
    );

    if (managers.length === 0) {
      return res.status(404).json({ message: 'Manager not found' });
    }

    // Create fund request (PENDING status)
    const [result] = await db.execute(
      `INSERT INTO operational_funds (from_user_id, to_user_id, amount, description, status) 
       VALUES (?, ?, ?, ?, ?)`,
      [manager_id, userId, parseFloat(amount), description || null, 'PENDING']
    );

    // Notify manager
    const [requester] = await db.execute('SELECT full_name FROM users WHERE id = ?', [userId]);
    const [managerRow] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [manager_id]);
    const manager = managerRow[0];

    await createNotification(
      manager_id,
      'FUND_REQUESTED',
      'New Fund Request',
      `${requester[0].full_name} has requested Rs. ${amount}.`,
      result.insertId
    );

    if (manager && manager.email) {
      await sendEmail(
        manager.email,
        'New Fund Request Received',
        `Dear ${manager.full_name},\n\n${requester[0].full_name} has requested a fund of Rs. ${amount}.\n\nDescription: ${description || 'No description provided'}\n\nBest regards,\nOffice Expense Management System`
      );
    }

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${userId}`).emit('fundUpdated');
      io.to(`user_${manager_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
    } catch (err) { }

    res.status(201).json({
      message: 'Fund requested successfully',
      requestId: result.insertId
    });
  } catch (error) {
    console.error('Request fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get operational funds
router.get('/operational', authenticateToken, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;
    const { type } = req.query; // 'sent' or 'received'

    let query = `
      SELECT op.*, 
             fu.full_name as from_user_name, fu.email as from_user_email,
             tu.full_name as to_user_name, tu.email as to_user_email
      FROM operational_funds op
      JOIN users fu ON op.from_user_id = fu.id
      JOIN users tu ON op.to_user_id = tu.id
      WHERE 1=1
    `;
    const params = [];

    if (type === 'sent') {
      query += ' AND op.from_user_id = ?';
      params.push(userId);
    } else if (type === 'received') {
      query += ' AND op.to_user_id = ?';
      params.push(userId);
    } else {
      // CEO sees all
      if (role === 'USER') {
        query += ' AND op.to_user_id = ?';
        params.push(userId);
      } else if (role === 'MANAGER') {
        query += ' AND (op.from_user_id = ? OR op.to_user_id = ?)';
        params.push(userId, userId);
      }
    }

    query += ' ORDER BY op.created_at DESC';

    const [funds] = await db.execute(query, params);

    res.json({ funds });
  } catch (error) {
    console.error('Get operational funds error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get single operational fund
router.get('/operational/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const role = req.user.role;
    const userId = req.user.id;

    const query = `
      SELECT op.*, 
             fu.full_name as from_user_name, fu.email as from_user_email,
             tu.full_name as to_user_name, tu.email as to_user_email
      FROM operational_funds op
      JOIN users fu ON op.from_user_id = fu.id
      JOIN users tu ON op.to_user_id = tu.id
      WHERE op.id = ?
    `;

    const [funds] = await db.execute(query, [id]);

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Fund record not found' });
    }

    const fund = funds[0];

    // Authorization: CEO sees all, otherwise must be sender or recipient
    if (role !== 'CEO' && fund.from_user_id !== userId && fund.to_user_id !== userId) {
      return res.status(403).json({ message: 'Unauthorized to view this fund record' });
    }

    res.json({ fund });
  } catch (error) {
    console.error('Get single fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


// Update operational fund (Allocation or Request)
router.put('/operational/:id', authenticateToken, chequeUpload.single('cheque_image'), async (req, res) => {
  try {
    const { id } = req.params;
    const {
      amount,
      description,
      payment_mode,
      cheque_number,
      bank_name,
      cheque_date,
      account_holder_name,
      upi_id,
      transaction_id
    } = req.body;
    const userId = req.user.id;

    const cheque_image_path = req.file ? req.file.path.replace(/\\/g, '/').split('uploads/')[1] ? 'uploads/' + req.file.path.replace(/\\/g, '/').split('uploads/')[1] : req.file.path : null;

    // Check if fund exists and belongs to user (either as sender or requester)
    const [funds] = await db.execute('SELECT * FROM operational_funds WHERE id = ?', [id]);

    if (funds.length === 0) {
      if (req.file) { require('fs').unlinkSync(req.file.path); }
      return res.status(404).json({ message: 'Fund record not found' });
    }

    const fund = funds[0];

    // Authorization: Sender can update, or Target Manager can update if it's a PENDING request
    const canUpdate = (fund.from_user_id === userId) || (fund.status === 'PENDING' && fund.to_user_id === userId);

    if (!canUpdate) {
      if (req.file) { require('fs').unlinkSync(req.file.path); }
      return res.status(403).json({ message: 'Unauthorized to update this fund record' });
    }

    if (fund.status !== 'PENDING' && fund.status !== 'ALLOCATED' && fund.status !== 'APPROVED') {
      if (req.file) { require('fs').unlinkSync(req.file.path); }
      return res.status(400).json({ message: 'Cannot edit fund record in current status' });
    }

    // Prepare update fields and values
    const updateFields = [];
    const values = [];

    if (amount !== undefined) { updateFields.push('amount = ?'); values.push(parseFloat(amount)); }
    if (description !== undefined) { updateFields.push('description = ?'); values.push(description || null); }
    if (payment_mode !== undefined) { updateFields.push('payment_mode = ?'); values.push(payment_mode || null); }
    if (cheque_number !== undefined) { updateFields.push('cheque_number = ?'); values.push(cheque_number || null); }
    if (bank_name !== undefined) { updateFields.push('bank_name = ?'); values.push(bank_name || null); }
    if (cheque_date !== undefined) { updateFields.push('cheque_date = ?'); values.push(cheque_date || null); }
    if (account_holder_name !== undefined) { updateFields.push('account_holder_name = ?'); values.push(account_holder_name || null); }
    if (cheque_image_path) { updateFields.push('cheque_image_path = ?'); values.push(cheque_image_path); }
    if (upi_id !== undefined) { updateFields.push('upi_id = ?'); values.push(upi_id || null); }
    if (transaction_id !== undefined) { updateFields.push('transaction_id = ?'); values.push(transaction_id || null); }

    if (updateFields.length === 0) {
      if (req.file) { require('fs').unlinkSync(req.file.path); }
      return res.json({ message: 'No changes provided' });
    }

    values.push(id);
    await db.execute(
      `UPDATE operational_funds SET ${updateFields.join(', ')} WHERE id = ?`,
      values
    );

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${fund.from_user_id}`).emit('fundUpdated');
      io.to(`user_${fund.to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
    } catch (err) { }

    res.json({ message: 'Fund record updated successfully' });

  } catch (error) {
    console.error('Update fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete operational fund (Allocation or Request)
router.delete('/operational/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if fund exists
    const [funds] = await db.execute('SELECT * FROM operational_funds WHERE id = ?', [id]);
    if (funds.length === 0) {
      return res.status(404).json({ message: 'Fund record not found' });
    }
    const fund = funds[0];

    // Authorization:
    // 1. Sender can delete if status is ALLOCATED (cancel allocation)
    // 2. Requester (to_user_id) can delete if status is PENDING (cancel request)

    let authorized = false;

    if (fund.from_user_id === userId && fund.status === 'ALLOCATED') {
      authorized = true;
    } else if (fund.to_user_id === userId && fund.status === 'PENDING') {
      // Requester can cancel request
      authorized = true;
    } else if (fund.from_user_id === userId && fund.status === 'PENDING') {
      // Manager can delete/cancel a pending request
      authorized = true;
    }
    // Also Manager can reject (which is technically an update), but user wants delete. 
    // Let's stick to cancelling own actions.

    if (!authorized) {
      return res.status(403).json({ message: 'Cannot delete: Unauthorized or invalid status' });
    }

    // Revert expansion fund status if linked
    if (fund.expansion_id) {
      await db.execute(
        'UPDATE expansion_funds SET status = "APPROVED" WHERE id = ?',
        [fund.expansion_id]
      );
    }

    // Revert expense status if description contains Expense ID
    if (fund.description) {
      const match = fund.description.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
      if (match) {
        const expenseId = match[1];
        console.log(`[Delete Allocation] Found linked Expense ID: ${expenseId}`);

        // Ensure we only revert if the current user (Manager/CEO) was the sender (Allocator)
        // Use loose equality or Number() to handle potential string/number mismatch
        if (Number(fund.from_user_id) === Number(userId)) {
          console.log(`[Delete Allocation] Reverting expense ${expenseId} status to RECEIPT_APPROVED`);
          await db.execute(
            'UPDATE expenses SET status = "RECEIPT_APPROVED" WHERE id = ?',
            [expenseId]
          );
        } else {
          console.log(`[Delete Allocation] User mismatch. Fund Sender: ${fund.from_user_id}, Current User: ${userId}`);
        }
      }
    }

    await db.execute('DELETE FROM operational_funds WHERE id = ?', [id]);

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${fund.from_user_id}`).emit('fundUpdated');
      io.to(`user_${fund.to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
      
      // If a linked expense status was reverted, notify all relevant parties
      const match = fund.description?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
      if (match) {
        io.emit('expenseUpdated'); // Simple broadcast for now, or targeted
      }
    } catch (err) { }

    res.json({ message: 'Fund record deleted successfully' });

  } catch (error) {
    console.error('Delete fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Confirm fund receipt (Manager/User)
router.put('/operational/:id/receive', authenticateToken, authorizeRoles('MANAGER', 'USER'), async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const [funds] = await db.execute(
      'SELECT * FROM operational_funds WHERE id = ? AND to_user_id = ?',
      [id, userId]
    );

    console.log('Confirm Receipt Debug:', {
      fundId: id,
      userId,
      found: funds.length > 0,
      fund: funds[0]
    });

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Fund not found' });
    }

    const fund = funds[0];

    if (fund.status === 'RECEIVED' || fund.status === 'COMPLETED') {
      return res.status(400).json({ message: 'Fund already received' });
    }

    await db.execute(
      'UPDATE operational_funds SET status = ?, received_at = NOW() WHERE id = ?',
      ['RECEIVED', id]
    );

    // Auto-complete linked expense if exists
    if (fund.description) {
      console.log('Checking for Expense ID in description:', fund.description);
      const match = fund.description.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
      if (match) {
        const expenseId = match[1];
        console.log('Extracted Expense ID:', expenseId);
        try {
          // Check who owns the expense
          const [expenseRows] = await db.execute('SELECT user_id FROM expenses WHERE id = ?', [expenseId]);

          if (expenseRows.length > 0) {
            const expenseOwnerId = expenseRows[0].user_id;

            // Only auto-complete if the expense belongs to the person confirming the receipt (Manager's own expense)
            if (Number(expenseOwnerId) === Number(userId)) {
              const [result] = await db.execute(
                'UPDATE expenses SET status = ?, receipt_confirmed_at = NOW() WHERE id = ?',
                ['COMPLETED', expenseId]
              );
              console.log('Auto-completed own expense:', result);
            } else {
              console.log('Expense belongs to another user. Not auto-completing. Waiting for allocation.');
            }
          }
        } catch (exErr) {
          console.error('Failed to update linked expense:', exErr);
          // Don't fail the fund receipt confirmation if expense update fails
        }
      } else {
        console.log('No Expense ID match found in description');
      }
    }
    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${fund.from_user_id}`).emit('fundUpdated');
      io.to(`user_${fund.to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
      // If an expense was updated, emit that too
      if (fund.description && fund.description.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i)) {
        io.to(`user_${userId}`).emit('expenseUpdated');
        io.to('role_CEO').emit('expenseUpdated');
        io.to('role_MANAGER').emit('expenseUpdated');
      }
    } catch (err) { }

    res.json({ message: 'Fund receipt confirmed' });
  } catch (error) {
    console.error('Confirm receipt error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Approve fund request (Manager)
router.put('/operational/:id/approve', authenticateToken, authorizeRoles('MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const managerId = req.user.id;

    // Verify request exists and is for this manager
    const [requests] = await db.execute(
      'SELECT * FROM operational_funds WHERE id = ? AND from_user_id = ? AND status = ?',
      [id, managerId, 'PENDING']
    );

    if (requests.length === 0) {
      return res.status(404).json({ message: 'Fund request not found or not pending' });
    }

    // Update status to APPROVED
    await db.execute(
      'UPDATE operational_funds SET status = ?, allocated_at = NOW() WHERE id = ?',
      ['APPROVED', id]
    );

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${requests[0].from_user_id}`).emit('fundUpdated');
      io.to(`user_${requests[0].to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
    } catch (err) { }

    res.json({ message: 'Fund request approved' });

    // Notify requester
    const [requesterRow] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [requests[0].to_user_id]);
    const requesterUser = requesterRow[0];

    await createNotification(
      requests[0].to_user_id,
      'FUND_REQUEST_APPROVED',
      'Fund Request Approved',
      `Your request for Rs. ${requests[0].amount} has been approved.`,
      id
    );

    if (requesterUser && requesterUser.email) {
      await sendEmail(
        requesterUser.email,
        'Fund Request Approved',
        `Dear ${requesterUser.full_name},\n\nYour fund request for Rs. ${requests[0].amount} has been approved.\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Approve fund request error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Allocate fund request (Manager - Step 2)
router.put('/operational/:id/allocate', authenticateToken, authorizeRoles('MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const managerId = req.user.id;

    // Verify request exists, is for this manager, and is APPROVED
    const [requests] = await db.execute(
      'SELECT * FROM operational_funds WHERE id = ? AND from_user_id = ? AND status = ?',
      [id, managerId, 'APPROVED']
    );

    if (requests.length === 0) {
      return res.status(404).json({ message: 'Fund request not found or not approved' });
    }

    // Update status to ALLOCATED
    await db.execute(
      'UPDATE operational_funds SET status = ?, allocated_at = NOW() WHERE id = ?',
      ['ALLOCATED', id]
    );

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${requests[0].from_user_id}`).emit('fundUpdated');
      io.to(`user_${requests[0].to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
    } catch (err) { }

    res.json({ message: 'Fund allocated successfully' });
  } catch (error) {
    console.error('Allocate fund request error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reject fund request (Manager)
router.put('/operational/:id/reject', authenticateToken, authorizeRoles('MANAGER'), async (req, res) => {
  try {
    const { id } = req.params;
    const managerId = req.user.id;
    const { rejection_reason } = req.body;

    // Verify request exists and is for this manager
    const [requests] = await db.execute(
      'SELECT * FROM operational_funds WHERE id = ? AND from_user_id = ? AND status = ?',
      [id, managerId, 'PENDING']
    );

    if (requests.length === 0) {
      return res.status(404).json({ message: 'Fund request not found or not pending' });
    }

    // Update status to REJECTED (assuming REJECTED was added to ENUM, if not use COMPLETED or delete?)
    // Using REJECTED as planned schema update should be done.
    await db.execute(
      'UPDATE operational_funds SET status = ?, rejection_reason = ? WHERE id = ?',
      ['REJECTED', rejection_reason || null, id]
    );

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${requests[0].from_user_id}`).emit('fundUpdated');
      io.to(`user_${requests[0].to_user_id}`).emit('fundUpdated');
      io.to('role_CEO').emit('fundUpdated');
    } catch (err) { }

    res.json({ message: 'Fund request rejected' });

    // Notify requester
    const [requesterRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [requests[0].to_user_id]);
    const requester = requesterRows[0];

    await createNotification(
      requests[0].to_user_id,
      'FUND_REQUEST_REJECTED',
      'Fund Request Rejected',
      `Your request for Rs. ${requests[0].amount} has been rejected. Reason: ${rejection_reason || 'No reason provided'}`,
      id
    );

    if (requester && requester.email) {
      await sendEmail(
        requester.email,
        'Fund Request Rejected',
        `Dear ${requester.full_name},\n\nYour fund request for Rs. ${requests[0].amount} has been rejected.\n\nReason: ${rejection_reason || 'No reason provided'}\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Reject fund request error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Request expansion fund (Manager only)
router.post('/expansion', authenticateToken, authorizeRoles('MANAGER'), async (req, res) => {
  try {
    const { requested_amount, justification } = req.body;
    const managerId = req.user.id;

    if (!requested_amount || !justification) {
      return res.status(400).json({ message: 'Requested amount and justification are required' });
    }

    const [result] = await db.execute(
      `INSERT INTO expansion_funds (manager_id, requested_amount, justification, status) 
       VALUES (?, ?, ?, ?)`,
      [managerId, parseFloat(requested_amount), justification, 'PENDING']
    );

    // Update linked expense status if confirmed
    const match = justification.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
    if (match) {
      const expenseId = match[1];
      await db.execute(
        'UPDATE expenses SET status = ? WHERE id = ?',
        ['EXPANSION_REQUESTED', expenseId]
      );
    }

    // Notify CEO
    const [ceos] = await db.execute('SELECT id, email, full_name FROM users WHERE role = "CEO"');
    const [manager] = await db.execute('SELECT full_name FROM users WHERE id = ?', [managerId]);
    for (const ceo of ceos) {
      await createNotification(
        ceo.id,
        'EXPANSION_REQUESTED',
        'New Expansion Fund Request',
        `${manager[0].full_name} has requested an expansion fund of Rs. ${requested_amount}.`,
        result.insertId
      );

      if (ceo.email) {
        try {
          await sendEmail(
            ceo.email,
            'New Expansion Fund Request Received',
            `Dear ${ceo.full_name},\n\nManager ${(manager[0] && manager[0].full_name) || 'Unknown'} has requested an expansion fund of Rs. ${requested_amount}.\n\nJustification: ${justification}\n\nBest regards,\nOffice Expense Management System`
          );
        } catch (emailErr) {
          console.error('Failed to send email to CEO:', emailErr);
        }
      }
    }

    res.status(201).json({
      message: 'Expansion fund request submitted successfully',
      requestId: result.insertId
    });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${managerId}`).emit('expansionUpdated');
      io.to('role_CEO').emit('expansionUpdated');
      // If an expense was updated, emit that too
      if (justification.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i)) {
        io.to('role_MANAGER').emit('expenseUpdated');
        io.to('role_CEO').emit('expenseUpdated');
      }
    } catch (err) { }
  } catch (error) {
    console.error('Request expansion fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get expansion funds
router.get('/expansion', authenticateToken, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;

    let query = `
      SELECT ef.*, 
             u.full_name as manager_name, u.email as manager_email,
             r.full_name as reviewer_name,
             op.cheque_image_path
      FROM expansion_funds ef
      JOIN users u ON ef.manager_id = u.id
      LEFT JOIN users r ON ef.reviewed_by = r.id
      LEFT JOIN operational_funds op ON ef.id = op.expansion_id
      WHERE 1=1
    `;
    const params = [];

    if (role === 'MANAGER') {
      query += ' AND ef.manager_id = ?';
      params.push(userId);
    }
    // CEO sees all

    query += ' ORDER BY ef.created_at DESC';

    const [funds] = await db.execute(query, params);

    res.json({ funds });
  } catch (error) {
    console.error('Get expansion funds error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get single expansion fund
router.get('/expansion/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const role = req.user.role;
    const userId = req.user.id;

    const query = `
      SELECT ef.*, 
             u.full_name as manager_name, u.email as manager_email,
             r.full_name as reviewer_name,
             op.cheque_image_path
      FROM expansion_funds ef
      JOIN users u ON ef.manager_id = u.id
      LEFT JOIN users r ON ef.reviewed_by = r.id
      LEFT JOIN operational_funds op ON ef.id = op.expansion_id
      WHERE ef.id = ?
    `;

    const [funds] = await db.execute(query, [id]);

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Expansion fund record not found' });
    }

    const fund = funds[0];

    // Authorization: CEO sees all, otherwise must be the manager who requested it
    if (role !== 'CEO' && fund.manager_id !== userId) {
      return res.status(403).json({ message: 'Unauthorized to view this expansion record' });
    }

    res.json({ request: fund });
  } catch (error) {

    console.error('Get single expansion error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


// Approve or reject expansion fund (CEO only)
router.put('/expansion/:id/review', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    const { id } = req.params;
    const { action, approved_amount, rejection_reason } = req.body;
    const reviewerId = req.user.id;

    if (!['APPROVE', 'REJECT'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action. Use APPROVE or REJECT' });
    }

    const [funds] = await db.execute(
      'SELECT * FROM expansion_funds WHERE id = ? AND status = ?',
      [id, 'PENDING']
    );

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Expansion fund request not found or already reviewed' });
    }

    if (action === 'APPROVE') {
      const amount = approved_amount || funds[0].requested_amount;
      await db.execute(
        `UPDATE expansion_funds 
         SET status = ?, approved_amount = ?, reviewed_by = ?, reviewed_at = NOW() 
         WHERE id = ?`,
        ['APPROVED', parseFloat(amount), reviewerId, id]
      );

      res.json({ message: 'Expansion fund request approved' });

      // Broadcast via Socket.io
      try {
        const io = getIO();
        io.to('role_CEO').emit('expansionUpdated');

        // Refresh associated expense UI if linked
        const match = funds[0].justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
        if (match) {
          io.emit('expenseUpdated');
        }
      } catch (err) { }

      // Notify manager
      const [mgrRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [funds[0].manager_id]);
      const managerUser = mgrRows[0];

      await createNotification(
        funds[0].manager_id,
        'EXPANSION_APPROVED',
        'Expansion Request Approved',
        `Your expansion request for Rs. ${funds[0].requested_amount} has been approved for Rs. ${approved_amount || funds[0].requested_amount}.`,
        id
      );

      if (managerUser && managerUser.email) {
        await sendEmail(
          managerUser.email,
          'Expansion Fund Request Approved',
          `Dear ${managerUser.full_name},\n\nYour expansion fund request for Rs. ${funds[0].requested_amount} has been approved for Rs. ${approved_amount || funds[0].requested_amount}.\n\nBest regards,\nOffice Expense Management System`
        );
      }
    } else {
      await db.execute(
        `UPDATE expansion_funds 
         SET status = ?, reviewed_by = ?, reviewed_at = NOW(), rejection_reason = ? 
         WHERE id = ?`,
        ['REJECTED', reviewerId, rejection_reason || 'No reason provided', id]
      );

      res.json({ message: 'Expansion fund request rejected' });

      // Notify manager
      const [mgrRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [funds[0].manager_id]);
      const managerUser = mgrRows[0];

      await createNotification(
        funds[0].manager_id,
        'EXPANSION_REJECTED',
        'Expansion Request Rejected',
        `Your expansion request for Rs. ${funds[0].requested_amount} has been rejected. Reason: ${rejection_reason || 'No reason provided'}`,
        id
      );

      if (managerUser && managerUser.email) {
        await sendEmail(
          managerUser.email,
          'Expansion Fund Request Rejected',
          `Dear ${managerUser.full_name},\n\nYour expansion fund request for Rs. ${funds[0].requested_amount} has been rejected.\n\nReason: ${rejection_reason || 'No reason provided'}\n\nBest regards,\nOffice Expense Management System`
        );
      }

      // Broadcast via Socket.io
      try {
        io.to('role_CEO').emit('expansionUpdated');

        // Refresh associated expense UI if linked
        const match = funds[0].justification?.match(/(?:\(ID:\s*|Expense\s*#)(\d+)/i);
        if (match) {
          io.emit('expenseUpdated');
        }
      } catch (err) { }
    }
  } catch (error) {
    console.error('Review expansion fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


// Update expansion fund request
router.put('/expansion/:id', authenticateToken, authorizeRoles('MANAGER', 'CEO'), async (req, res) => {
  try {
    const { id } = req.params;
    const { requested_amount, justification } = req.body;
    const userId = req.user.id;
    const role = req.user.role;

    const [funds] = await db.execute('SELECT * FROM expansion_funds WHERE id = ?', [id]);

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Expansion fund request not found' });
    }

    const fund = funds[0];

    // Authorization: 
    // Manager can edit their own PENDING requests
    // CEO can edit any PENDING request? Or maybe just their own if they could make them? (CEO doesn't make expansion requests usually, they review them).
    // Let's assume this is primarily for the Manager to fix a mistake, OR for CEO to edit before approving?
    // Project requirement says "CEO Edit/Delete". Let's allow CEO to edit any PENDING request.

    if (fund.status !== 'PENDING' && fund.status !== 'REJECTED') {
      return res.status(400).json({ message: 'Cannot edit expansion request in current status' });
    }

    if (role === 'MANAGER' && fund.manager_id !== userId) {
      return res.status(403).json({ message: 'Unauthorized to edit this request' });
    }

    await db.execute(
      'UPDATE expansion_funds SET requested_amount = ?, justification = ?, status = "PENDING", reviewed_by = NULL, reviewed_at = NULL, rejection_reason = NULL WHERE id = ?',
      [requested_amount || fund.requested_amount, justification || fund.justification, id]
    );

    res.json({ message: 'Expansion fund request updated successfully' });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${fund.manager_id}`).emit('expansionUpdated');
      io.to('role_CEO').emit('expansionUpdated');
    } catch (err) { }

  } catch (error) {
    console.error('Update expansion fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete expansion fund request
router.delete('/expansion/:id', authenticateToken, authorizeRoles('MANAGER', 'CEO'), async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const role = req.user.role;

    const [funds] = await db.execute('SELECT * FROM expansion_funds WHERE id = ?', [id]);

    if (funds.length === 0) {
      return res.status(404).json({ message: 'Expansion fund request not found' });
    }

    const fund = funds[0];

    if (fund.status !== 'PENDING' && fund.status !== 'REJECTED') {
      return res.status(400).json({ message: 'Cannot delete expansion request in current status' });
    }

    if (role === 'MANAGER' && fund.manager_id !== userId) {
      return res.status(403).json({ message: 'Unauthorized to delete this request' });
    }

    await db.execute('DELETE FROM expansion_funds WHERE id = ?', [id]);

    res.json({ message: 'Expansion fund request deleted successfully' });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.to(`user_${fund.manager_id}`).emit('expansionUpdated');
      io.to('role_CEO').emit('expansionUpdated');
    } catch (err) { }

  } catch (error) {
    console.error('Delete expansion fund error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
