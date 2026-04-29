# Database Setup Instructions

## Quick Setup

1. **Create the database:**
```sql
CREATE DATABASE OEMS;
```

2. **Import the schema:**
```bash
mysql -u root -p OEMS < database/schema.sql
```

3. **Initialize CEO account:**
```bash
cd backend
node scripts/init-ceo.js
```

## Schema Overview

The database contains the following tables:

- **users**: Stores all user accounts (CEO, Managers, Users)
- **expenses**: Stores expense records
- **expense_documents**: Stores uploaded voucher/document information
- **operational_funds**: Tracks fund allocation between users
- **expansion_funds**: Tracks expansion fund requests from Managers
- **expansion_fund_documents**: Stores expansion fund documents

## Default CEO Account

After running the init script, the CEO account will be:
- **Email**: ceo@gmail.com
- **Password**: 123Milople
- All account password is: 123Milople

**Important**: The CEO account is pre-created and always has APPROVED status.
