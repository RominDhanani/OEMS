/**
 * Office Expense Management - Backend Server
 * Main entry point for the Express application.
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const http = require('http');
const server = http.createServer(app);
const io = require('./utils/socket').init(server);

/**
 * Middleware Configuration
 */
app.use(cors()); // Enable Cross-Origin Resource Sharing
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

/**
 * Static File Serving
 * Serves uploaded documents and images from the 'uploads' directory.
 */
app.use('/uploads', express.static(process.env.VERCEL === '1' ? '/tmp/uploads' : path.join(__dirname, 'uploads')));

/**
 * API Route Definitions
 */
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/expenses', require('./routes/expenses'));
app.use('/api/funds', require('./routes/funds'));
app.use('/api/reports', require('./routes/reports'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/migrate', require('./routes/migrate')); // Temporary migration route

/**
 * Health Check Endpoint
 */
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running', timestamp: new Date() });
});

/**
 * Global Error Handling Middleware
 * Catch-all for any errors thrown in routes.
 */
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err.stack);
  res.status(500).json({
    message: err.message || 'Something went wrong on the server!',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

const PORT = process.env.PORT || 5000;

/**
 * System Checks and Initialization
 */

// Verify critical environment variables
if (!process.env.JWT_SECRET) {
  console.warn('WARNING: JWT_SECRET is not set in environment variables!');
  console.warn('Please set JWT_SECRET in your .env file for authentication to work.');
}

// Test database connection on startup
const db = require('./config/database');
(async () => {
  try {
    await db.execute('SELECT 1');
    console.log('Database connection established successfully.');
  } catch (err) {
    console.error('CRITICAL: Database connection failed:', err.message);
    console.warn('The server will continue to run, but API endpoints requiring database access will fail.');
    console.warn('Please ensure your MySQL service is running and configured in the .env file.');
  }
})();

/**
 * Start the Server
 */
if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Local Access: http://localhost:${PORT}`);
    console.log(`Network Access: http://192.168.0.193:${PORT}`);
  });
}

module.exports = app;
