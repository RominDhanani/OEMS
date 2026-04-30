const db = require('./config/database');
async function checkEnum() {
  try {
    const [rows] = await db.execute('SHOW COLUMNS FROM expansion_funds LIKE "status"');
    console.log('Expansion Funds Status:', rows[0].Type);
    const [rows2] = await db.execute('SHOW COLUMNS FROM operational_funds LIKE "status"');
    console.log('Operational Funds Status:', rows2[0].Type);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
checkEnum();
