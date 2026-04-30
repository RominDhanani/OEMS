const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res) => {
  try {
    console.log('Remote Migration Triggered...');
    
    await db.execute(`
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
    
    console.log('Remote Migration Success!');
    res.json({ message: 'Database migration successful! Status ENUM updated.' });
  } catch (error) {
    console.error('Remote Migration Error:', error);
    res.status(500).json({ 
      message: 'Migration failed', 
      error: error.message 
    });
  }
});

module.exports = router;
