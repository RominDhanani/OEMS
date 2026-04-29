const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const moment = require('moment');

// Get expense reports
router.get('/expenses', authenticateToken, async (req, res) => {
  try {
    const { type, start_date, end_date, category, user_id, scope } = req.query;
    const role = req.user.role;
    const userId = req.user.id;

    let query = `
      SELECT e.*, u.full_name, u.email, u.role as user_role,
             au.full_name as approved_by_name
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
      if (scope === 'me') {
        // Manager's own expenses only
        query += ' AND e.user_id = ?';
        params.push(userId);
      } else {
        // Default: Manager's own + Team (Users)
        query += ' AND (e.user_id = ? OR u.role = ?)';
        params.push(userId, 'USER');
      }
    }
    // CEO sees all by default, no extra filtering needed unless specific filters applied

    if (category) {
      query += ' AND e.category = ?';
      params.push(category);
    }

    if (req.query.department) {
      query += ' AND e.department = ?';
      params.push(req.query.department);
    }

    if (type === 'user' && user_id && (role === 'CEO' || role === 'MANAGER')) {
      query += ' AND e.user_id = ?';
      params.push(user_id);
    }

    if (start_date) {
      query += ' AND e.expense_date >= ?';
      params.push(start_date);
    }

    if (end_date) {
      query += ' AND e.expense_date <= ?';
      params.push(end_date);
    }

    query += ' ORDER BY e.expense_date DESC';

    const [expenses] = await db.execute(query, params);

    // Aggregate data based on report type
    let reportData = {};

    if (type === 'category') {
      const categoryTotals = {};
      expenses.forEach(expense => {
        if (!categoryTotals[expense.category]) {
          categoryTotals[expense.category] = { count: 0, total: 0 };
        }
        categoryTotals[expense.category].count++;
        categoryTotals[expense.category].total += parseFloat(expense.amount);
      });
      reportData = Object.keys(categoryTotals).map(cat => ({
        category: cat,
        ...categoryTotals[cat]
      }));
    } else if (type === 'user') {
      const userTotals = {};
      expenses.forEach(expense => {
        const key = expense.user_id;
        if (!userTotals[key]) {
          userTotals[key] = {
            user_id: expense.user_id,
            user_name: expense.full_name,
            user_email: expense.email,
            count: 0,
            total: 0
          };
        }
        userTotals[key].count++;
        userTotals[key].total += parseFloat(expense.amount);
      });
      reportData = Object.values(userTotals);
    } else if (type === 'date') {
      const dateTotals = {};
      expenses.forEach(expense => {
        const date = moment(expense.expense_date).format('YYYY-MM-DD');
        if (!dateTotals[date]) {
          dateTotals[date] = { date, count: 0, total: 0 };
        }
        dateTotals[date].count++;
        dateTotals[date].total += parseFloat(expense.amount);
      });
      reportData = Object.values(dateTotals).sort((a, b) => new Date(b.date) - new Date(a.date));
    } else {
      reportData = expenses;
    }

    res.json({ reportType: type || 'all', data: reportData, totalRecords: expenses.length });
  } catch (error) {
    console.error('Get expense reports error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get fund flow reports
router.get('/funds', authenticateToken, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;
    const { type, scope, start_date, end_date } = req.query; // 'ceo-manager' or 'manager-user', 'scope'='me'|'team'

    let query = `
      SELECT op.*, 
             fu.full_name as from_user_name, fu.email as from_user_email, fu.role as from_role,
             tu.full_name as to_user_name, tu.email as to_user_email, tu.role as to_role
      FROM operational_funds op
      JOIN users fu ON op.from_user_id = fu.id
      JOIN users tu ON op.to_user_id = tu.id
      WHERE 1=1
    `;
    const params = [];

    if (type === 'ceo-manager') {
      query += ' AND fu.role = ? AND tu.role = ?';
      params.push('CEO', 'MANAGER');
    } else if (type === 'manager-user') {
      query += ' AND fu.role = ? AND tu.role = ?';
      params.push('MANAGER', 'USER');
    }

    // Role-based filtering
    if (role === 'USER') {
      query += ' AND op.to_user_id = ?';
      params.push(userId);
    } else if (role === 'MANAGER') {
      if (scope === 'me') {
        query += ' AND op.from_user_id = ?';
        params.push(userId);
      } else {
        query += ' AND (op.from_user_id = ? OR op.to_user_id = ?)';
        params.push(userId, userId);
      }
    }

    if (start_date) {
      query += ' AND op.created_at >= ?';
      params.push(start_date + ' 00:00:00');
    }
    if (end_date) {
      query += ' AND op.created_at <= ?';
      params.push(end_date + ' 23:59:59');
    }

    query += ' ORDER BY op.created_at DESC';

    const [funds] = await db.execute(query, params);

    res.json({ funds, totalRecords: funds.length });
  } catch (error) {
    console.error('Get fund reports error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get expansion fund reports
router.get('/expansion', authenticateToken, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;
    const { status, start_date, end_date } = req.query;

    let query = `
      SELECT ef.*, 
             u.full_name as manager_name, u.email as manager_email, u.role as manager_role,
             r.full_name as reviewer_name, r.role as reviewer_role
      FROM expansion_funds ef
      JOIN users u ON ef.manager_id = u.id
      LEFT JOIN users r ON ef.reviewed_by = r.id
      WHERE 1=1
    `;
    const params = [];

    if (role === 'MANAGER') {
      query += ' AND ef.manager_id = ?';
      params.push(userId);
    }

    if (status) {
      query += ' AND ef.status = ?';
      params.push(status);
    }

    if (start_date) {
      query += ' AND ef.created_at >= ?';
      params.push(start_date + ' 00:00:00');
    }

    if (end_date) {
      query += ' AND ef.created_at <= ?';
      params.push(end_date + ' 23:59:59');
    }

    query += ' ORDER BY ef.created_at DESC';

    const [funds] = await db.execute(query, params);

    // Calculate totals
    const totals = {
      total_requested: 0,
      total_approved: 0,
      pending_count: 0,
      approved_count: 0,
      rejected_count: 0
    };

    funds.forEach(fund => {
      totals.total_requested += parseFloat(fund.requested_amount || 0);
      totals.total_approved += parseFloat(fund.approved_amount || 0);
      if (fund.status === 'PENDING') totals.pending_count++;
      else if (fund.status === 'APPROVED') totals.approved_count++;
      else if (fund.status === 'REJECTED') totals.rejected_count++;
    });

    res.json({ funds, totals, totalRecords: funds.length });
  } catch (error) {
    console.error('Get expansion reports error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get dashboard statistics
router.get('/dashboard', authenticateToken, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;

    const stats = {};

    // Expense statistics
    // 1. Own Expenses (User, Manager, CEO personal)
    const [ownExpenses] = await db.execute(
      `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
       FROM expenses 
       WHERE user_id = ? 
       GROUP BY status`,
      [userId]
    );
    stats.ownExpenses = ownExpenses;

    // 2. Team Expenses (Manager Only)
    if (role === 'MANAGER') {
      const [teamExpenses] = await db.execute(
        `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
         FROM expenses 
         WHERE user_id IN (SELECT id FROM users WHERE manager_id = ?) 
         GROUP BY status`,
        [userId]
      );
      stats.teamExpenses = teamExpenses;
    }

    // 3. All Expenses (CEO Only)
    if (role === 'CEO') {
      const [allExpenses] = await db.execute(
        `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
         FROM expenses 
         GROUP BY status`
      );
      stats.expenses = allExpenses;
    } else {
      // For legacy compatibility, map own + team to 'expenses' if needed, 
      // but usually the frontend uses 'expenses' for the main list or total.
      // Let's keep 'stats.expenses' as the aggregate for the view context.
      if (role === 'MANAGER') {
        // Aggregate own + team for "Total Expenses" view if useful, or just own.
        // The previous logic for MANAGER was: user_id IN (me OR team).
        const [totalExpenses] = await db.execute(
          `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
             FROM expenses 
             WHERE user_id = ? OR user_id IN (SELECT id FROM users WHERE manager_id = ?)
             GROUP BY status`,
          [userId, userId]
        );
        stats.expenses = totalExpenses;
      } else {
        stats.expenses = ownExpenses;
      }
    }

    // Fund statistics
    // 1. Allocated Funds (Funds I gave to others)
    if (role === 'CEO' || role === 'MANAGER') {
      const [fundStats] = await db.execute(
        `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
         FROM operational_funds 
         WHERE from_user_id = ? 
         GROUP BY status`,
        [userId]
      );
      stats.allocatedFunds = fundStats;
    }

    // 2. Received Funds (Funds I received)
    if (role === 'MANAGER' || role === 'USER') {
      const [receivedStats] = await db.execute(
        `SELECT COUNT(*) as total, SUM(amount) as total_amount, status 
         FROM operational_funds 
         WHERE to_user_id = ? 
         GROUP BY status`,
        [userId]
      );
      stats.receivedFunds = receivedStats;
    }

    // Pending approvals
    if (role === 'CEO' || role === 'MANAGER') {
      let approvalQuery = 'SELECT COUNT(*) as count FROM expenses WHERE status = ?';
      const approvalParams = ['PENDING_APPROVAL'];

      if (role === 'MANAGER') {
        approvalQuery += ' AND user_id IN (SELECT id FROM users WHERE manager_id = ?)';
        approvalParams.push(userId);
      }

      const [approvals] = await db.execute(approvalQuery, approvalParams);
      stats.pendingApprovals = approvals[0].count;
    }

    // Pending user approvals (CEO only)
    if (role === 'CEO') {
      const [pendingUsers] = await db.execute(
        'SELECT COUNT(*) as count FROM users WHERE status = ?',
        ['PENDING']
      );
      stats.pendingUsers = pendingUsers[0].count;
    }

    // Expansion funds (Manager)
    if (role === 'MANAGER') {
      const [expansionStats] = await db.execute(
        `SELECT COUNT(*) as total, SUM(requested_amount) as total_requested, SUM(approved_amount) as total_approved, status 
         FROM expansion_funds 
         WHERE manager_id = ? 
         GROUP BY status`,
        [userId]
      );
      stats.expansionFunds = expansionStats;
    }

    // Expansion funds (CEO)
    if (role === 'CEO') {
      const [expansionPending] = await db.execute(
        'SELECT COUNT(*) as count FROM expansion_funds WHERE status = ?',
        ['PENDING']
      );
      stats.pendingExpansionRequests = expansionPending[0].count;
    }

    res.json({ stats });
  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get allocation and usage reports (CEO Overview)
router.get('/allocation-usage', authenticateToken, authorizeRoles('CEO'), async (req, res) => {
  try {
    // 1. Get all Managers
    const [managers] = await db.execute(
      `SELECT id, full_name, email FROM users WHERE role = 'MANAGER' AND status = 'APPROVED'`
    );

    const report = [];

    for (const manager of managers) {
      // 2. Get funds received by Manager (from CEO)
      const [receivedFunds] = await db.execute(
        `SELECT SUM(amount) as total FROM operational_funds 
         WHERE to_user_id = ? AND status = 'RECEIVED'`,
        [manager.id]
      );
      const totalReceived = parseFloat(receivedFunds[0].total || 0);

      // 3. Get expenses by Manager (Manager's own expenses)
      const [managerExpenses] = await db.execute(
        `SELECT SUM(amount) as total FROM expenses 
         WHERE user_id = ? AND status != 'REJECTED'`,
        [manager.id]
      );
      const totalManagerExpenses = parseFloat(managerExpenses[0].total || 0);

      // 4. Get Manager's Users (Team)
      const [users] = await db.execute(
        `SELECT id, full_name, email FROM users WHERE manager_id = ? AND status = 'APPROVED'`,
        [manager.id]
      );

      const teamData = [];
      let totalAllocatedToTeam = 0;

      for (const user of users) {
        // 5. Get funds allocated to User (by Manager)
        const [userFunds] = await db.execute(
          `SELECT SUM(amount) as total FROM operational_funds 
           WHERE to_user_id = ? AND from_user_id = ? AND status = 'RECEIVED'`,
          [user.id, manager.id]
        );
        const userReceived = parseFloat(userFunds[0].total || 0);
        totalAllocatedToTeam += userReceived;

        // 6. Get User's expenses
        const [userExpenses] = await db.execute(
          `SELECT SUM(amount) as total FROM expenses 
           WHERE user_id = ? AND status != 'REJECTED'`,
          [user.id]
        );
        const totalUserExpenses = parseFloat(userExpenses[0].total || 0);

        teamData.push({
          id: user.id,
          name: user.full_name,
          email: user.email,
          allocated_fund: userReceived,
          used_fund: totalUserExpenses,
          balance: userReceived - totalUserExpenses
        });
      }

      report.push({
        manager_id: manager.id,
        manager_name: manager.full_name,
        manager_email: manager.email,
        total_received: totalReceived,
        total_allocated_to_team: totalAllocatedToTeam,
        items_allocated_fund: totalReceived, // Total fund manager holds
        manager_own_usage: totalManagerExpenses, // Manager's personal expenses
        team_usage_breakdown: teamData,
        manager_balance: totalReceived - totalManagerExpenses - totalAllocatedToTeam
      });
    }

    res.json({ report });
  } catch (error) {
    console.error('Get allocation usage error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
