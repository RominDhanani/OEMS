require('dotenv').config();
const db = require('../config/database');

async function migrate() {
  try {
    console.log('Starting migration...');

    // 1. Add EXPANSION_REQUESTED to expenses status enum
    // Note: We include all current valid statuses to be safe
    console.log('Updating expenses table status enum...');
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
    console.log('Expenses table enum updated.');

    // 2. Migrate any existing 'CREATED' statuses to 'PENDING_APPROVAL'
    // (In case any records were somehow created despite the enum error, or for backward compatibility)
    // Actually, since it's an enum, 'CREATED' wouldn't exist unless it was added before.
    // But let's check if we need to add it to the enum temporarily to fix data.
    // Since 'Data truncated' happened, 'CREATED' likely doesn't exist in the table.

    console.log('Migration completed successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
