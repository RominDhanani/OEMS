const jwt = require('jsonwebtoken');
const db = require('../config/database');

const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Validate session in user_sessions table
    const [sessions] = await db.execute(
      'SELECT id FROM user_sessions WHERE user_id = ? AND token = ? AND active = true',
      [decoded.userId, token]
    );

    if (sessions.length === 0) {
      return res.status(401).json({ message: 'Session expired or revoked from another device.' });
    }

    // Verify user still exists and is approved
    const [users] = await db.execute(
      'SELECT id, email, role, status FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'User not found' });
    }

    if (users[0].status !== 'APPROVED') {
      return res.status(403).json({ message: 'Account not approved' });
    }

    req.user = users[0];
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Invalid or expired token' });
  }
};

const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Insufficient permissions' });
    }

    next();
  };
};

module.exports = { authenticateToken, authorizeRoles };
