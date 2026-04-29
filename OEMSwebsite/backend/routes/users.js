const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createNotification } = require('../utils/notifications');
const { sendEmail } = require('../utils/mailer');

// Get all pending users (CEO only)
router.get('/pending', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    const [users] = await db.execute(
      'SELECT id, email, full_name, role, status, created_at FROM users WHERE status = ? ORDER BY created_at DESC',
      ['PENDING']
    );

    res.json({ users });
  } catch (error) {
    console.error('Get pending users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all users (CEO only)
router.get('/', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    const [users] = await db.execute(
      `SELECT u.id, u.email, u.full_name, u.mobile_number, u.role, u.status, u.created_at, u.manager_id, m.full_name as manager_name 
       FROM users u 
       LEFT JOIN users m ON u.manager_id = m.id 
       ORDER BY u.created_at DESC`
    );

    res.json({ users });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Approve or reject user (CEO only)
router.put('/:id/approve', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    const { id } = req.params;
    let { action } = req.body; // 'APPROVE' or 'REJECT'

    console.log('Approve User Request:', { id, action, user: req.user });

    if (action) action = action.toUpperCase();

    if (!['APPROVE', 'REJECT', 'ACTIVATE', 'DEACTIVATE'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action. Use APPROVE, REJECT, ACTIVATE, or DEACTIVATE' });
    }

    let status;
    if (action === 'APPROVE' || action === 'ACTIVATE') {
      status = 'APPROVED';
    } else if (action === 'DEACTIVATE') {
      status = 'DEACTIVATED';
    } else {
      status = 'REJECTED';
    }

    const [result] = await db.execute(
      'UPDATE users SET status = ? WHERE id = ?',
      [status, id]
    );

    // Fetch user email for notification
    const [userRows] = await db.execute('SELECT email, full_name FROM users WHERE id = ?', [id]);
    const userEmail = userRows[0]?.email;
    const userFullName = userRows[0]?.full_name;

    console.log('Update Result:', result);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: `User ${action.toLowerCase()}d successfully` });
    
    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.emit('userUpdated');
    } catch (err) { }

    // Notify user
    let title = 'Account Status Updated';
    let message = `Your account status has been updated to ${status}.`;
    if (status === 'APPROVED') {
      title = 'Account Approved';
      message = 'Your account has been approved by the CEO. You can now access your dashboard.';
    } else if (status === 'REJECTED') {
      title = 'Account Rejected';
      message = 'Your registration request has been rejected by the CEO.';
    } else if (status === 'DEACTIVATED') {
      title = 'Account Deactivated';
      message = 'Your account has been deactivated by the CEO.';
    }

    await createNotification(id, 'ACCOUNT_STATUS', title, message, id);

    if (userEmail) {
      await sendEmail(
        userEmail,
        title,
        `Dear ${userFullName},\n\n${message}\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Approve user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Assign manager to user (CEO only)
router.put('/:id/assign-manager', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    const { id } = req.params;
    const { manager_id } = req.body;

    // Verify user exists
    const [users] = await db.execute('SELECT id FROM users WHERE id = ?', [id]);
    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Verify manager exists and is actually a manager (if manager_id provided)
    if (manager_id) {
      const [managers] = await db.execute('SELECT id FROM users WHERE id = ? AND role = "MANAGER"', [manager_id]);
      if (managers.length === 0) {
        return res.status(400).json({ message: 'Invalid manager ID' });
      }
    }

    await db.execute(
      'UPDATE users SET manager_id = ? WHERE id = ?',
      [manager_id || null, id]
    );

    res.json({ message: 'Manager assigned successfully' });

    // Broadcast via Socket.io
    try {
      const io = getIO();
      io.emit('userUpdated');
    } catch (err) { }

    // Notify user
    const [managerRows] = await db.execute('SELECT full_name, email FROM users WHERE id = ?', [manager_id]);
    const [userRows] = await db.execute('SELECT full_name, email FROM users WHERE id = ?', [id]);
    const manager = managerRows[0];
    const user = userRows[0];

    await createNotification(
      id,
      'MANAGER_ASSIGNED',
      'Manager Assigned',
      manager_id
        ? `You have been assigned to manager: ${manager.full_name}.`
        : 'You are no longer assigned to a manager.',
      id
    );

    if (user && user.email) {
      await sendEmail(
        user.email,
        'Manager Assignment Update',
        `Dear ${user.full_name},\n\nThe CEO has updated your manager assignment.\n\n${manager_id
          ? `You have been assigned to manager: ${manager.full_name}.`
          : 'You are no longer assigned to a manager.'}\n\nBest regards,\nOffice Expense Management System`
      );
    }

    // Notify manager
    if (manager_id && manager && manager.email) {
      await createNotification(
        manager_id,
        'USER_ASSIGNED',
        'New User Assigned',
        `${user.full_name} has been assigned to you.`,
        id
      );

      await sendEmail(
        manager.email,
        'New User Assignment',
        `Dear ${manager.full_name},\n\nThe CEO has assigned a new user to your team.\n\n${user.full_name} has been assigned to you as a direct report.\n\nBest regards,\nOffice Expense Management System`
      );
    }
  } catch (error) {
    console.error('Assign manager error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get managers list (for User/CEO/Manager)
router.get('/managers', authenticateToken, authorizeRoles('CEO', 'MANAGER', 'USER'), async (req, res) => {
  try {
    const userRole = req.user.role;
    const userId = req.user.id;

    let query = 'SELECT id, email, full_name, role, status FROM users WHERE role = ? AND status = ?';
    let params = ['MANAGER', 'APPROVED'];

    if (userRole === 'USER') {
      const [user] = await db.execute('SELECT manager_id FROM users WHERE id = ?', [userId]);
      if (user.length > 0 && user[0].manager_id) {
        query += ' AND id = ?';
        params.push(user[0].manager_id);
      }
    }

    const [managers] = await db.execute(query, params);

    res.json({ managers });
  } catch (error) {
    console.error('Get managers error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get users list (for Manager)
router.get('/users', authenticateToken, authorizeRoles('MANAGER'), async (req, res) => {
  try {
    const [users] = await db.execute(
      'SELECT id, email, full_name, role, status, manager_id FROM users WHERE role = ? AND status = ? AND manager_id = ?',
      ['USER', 'APPROVED', req.user.id]
    );

    res.json({ users });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
