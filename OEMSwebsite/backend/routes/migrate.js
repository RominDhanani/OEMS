const express = require('express');
const router = express.Router();
const mysql = require('mysql2/promise');

router.get('/', async (req, res) => {
  try {
    console.log('Remote Migration Triggered with direct connection...');
    
    // Create a direct connection to bypass any pool issues
    const connection = await mysql.createConnection({
      host: '64.227.146.147', // Direct IP
      port: 20336,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      ssl: { rejectUnauthorized: false }
    });

    await connection.execute(`
      ALTER TABLE expenses 
      MODIFY COLUMN status ENUM(
        'PENDING_APPROVAL',
        'APPROVED',
        'REJECTED',
        'RECEIPT_APPROVED',
        'FUND_ALLOCATED',
        'COMPLETED',
        'EXPANSION_REQUESTED'
      ) DEFAULT 'PENDING_APPROVAL'
    `);
    
    await connection.end();
    
    console.log('Remote Migration Success with IP!');
    res.json({ message: 'Database migration successful using direct IP! Status ENUM updated.' });
  } catch (error) {
    console.error('Remote Migration Error:', error);
    res.status(500).json({ 
      message: 'Migration failed', 
      error: error.message,
      code: error.code
    });
  }
});

module.exports = router;
