const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'expense_management',
  waitForConnections: true,
  connectionLimit: 10
});

async function initCEO() {
  try {
    const email = 'ceo@gmail.com';
    const password = '123@Milople';
    const hashedPassword = await bcrypt.hash(password, 10);

    // Check if CEO already exists
    const [results] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (results.length > 0) {
      // Update existing CEO password
      await pool.execute(
        'UPDATE users SET password = ?, status = ? WHERE email = ?',
        [hashedPassword, 'APPROVED', email]
      );
      console.log('CEO password updated successfully');
      console.log('Email:', email);
      console.log('Password:', password);
    } else {
      // Insert new CEO
      await pool.execute(
        'INSERT INTO users (email, password, full_name, role, status) VALUES (?, ?, ?, ?, ?)',
        [email, hashedPassword, 'CEO User', 'CEO', 'APPROVED']
      );
      console.log('CEO account created successfully');
      console.log('Email:', email);
      console.log('Password:', password);
    }

    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    await pool.end();
    process.exit(1);
  }
}

initCEO();
