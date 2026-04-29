# Office Expense Management System

A comprehensive web-based expense management system with multi-level user roles, approvals, fund allocation, and document management.

## Features

- **Multi-level User Roles**: CEO, Manager, and General User
- **User Registration & Approval**: New users require CEO approval
- **Expense Management**: Create expenses with mandatory voucher/document upload
- **Fund Allocation**: Operational funds (CEO→Manager, Manager→User) and Expansion funds
- **Document Management**: Upload and download vouchers (PDF, JPG, PNG)
- **Dashboards**: Role-specific dashboards with comprehensive features
- **Reports**: Expense, fund, and expansion fund reports

## Tech Stack

- **Frontend**: React.js with Vite
- **Backend**: Node.js with Express.js
- **Database**: MySQL
- **Authentication**: JWT tokens
- **File Upload**: Multer

## Installation & Setup

### Prerequisites

- Node.js (v14 or higher)
- MySQL (v5.7 or higher)
- npm or yarn

### Database Setup

1. Create a MySQL database:
```sql
CREATE DATABASE expense_management;
```

2. Import the schema:
```bash
mysql -u root -p expense_management < database/schema.sql
```

3. Initialize CEO account:
```bash
cd backend
node scripts/init-ceo.js
```

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file (copy from `.env.example`):
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=expense_management

PORT=5000
NODE_ENV=development

JWT_SECRET=your_super_secret_jwt_key_change_this_in_production

UPLOAD_DIR=uploads
MAX_FILE_SIZE=10485760
```

4. Start the backend server:
```bash
npm start
# or for development with auto-reload
npm run dev
```

The backend will run on `http://localhost:5000`

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

The frontend will run on `http://localhost:3000`

## Default CEO Credentials

- **Email**: ceo@expenses.com
- **Password**: CEO@123456

## User Roles & Permissions

### CEO
- Pre-created account (always approved)
- Approve/reject user registrations
- Create expenses with vouchers
- Approve all expenses
- Allocate operational funds to Managers
- Approve/reject expansion fund requests
- View all reports and vouchers

### Manager
- Register (requires CEO approval)
- Create expenses with vouchers
- Approve User expenses
- Allocate operational funds to Users
- Request expansion funds from CEO
- View reports and vouchers within scope

### General User
- Register (requires CEO approval)
- Create expenses with vouchers
- View own expenses and vouchers
- Confirm fund receipt

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user

### Users
- `GET /api/users/pending` - Get pending users (CEO only)
- `PUT /api/users/:id/approve` - Approve/reject user (CEO only)

### Expenses
- `POST /api/expenses` - Create expense with vouchers
- `GET /api/expenses` - Get expenses (role-filtered)
- `GET /api/expenses/:id` - Get expense details
- `PUT /api/expenses/:id/approve` - Approve expense
- `PUT /api/expenses/:id/reject` - Reject expense
- `GET /api/expenses/:id/documents/:docId` - Download voucher

### Funds
- `POST /api/funds/operational` - Allocate operational fund
- `GET /api/funds/operational` - Get operational funds
- `PUT /api/funds/operational/:id/receive` - Confirm fund receipt
- `POST /api/funds/expansion` - Request expansion fund (Manager only)
- `GET /api/funds/expansion` - Get expansion funds
- `PUT /api/funds/expansion/:id/review` - Review expansion fund (CEO only)

### Reports
- `GET /api/reports/expenses` - Get expense reports
- `GET /api/reports/funds` - Get fund reports
- `GET /api/reports/expansion` - Get expansion fund reports
- `GET /api/reports/dashboard` - Get dashboard statistics

## Project Structure

```
expenses-3/
├── backend/
│   ├── config/
│   │   ├── database.js
│   │   └── multer.js
│   ├── middleware/
│   │   └── auth.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── expenses.js
│   │   ├── funds.js
│   │   └── reports.js
│   ├── scripts/
│   │   └── init-ceo.js
│   ├── uploads/
│   │   ├── expenses/
│   │   └── expansion-funds/
│   ├── server.js
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── context/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── package.json
│   └── vite.config.js
├── database/
│   ├── schema.sql
│   └── init-ceo.sql
└── README.md
```

## File Upload

- Supported formats: PDF, JPG, PNG
- Maximum file size: 10MB (configurable)
- Files are stored in `backend/uploads/`
- Expense vouchers: `backend/uploads/expenses/`
- Expansion fund documents: `backend/uploads/expansion-funds/`

## Development Notes

- Ensure MySQL is running before starting the backend
- Create the `uploads` directory structure before uploading files
- JWT tokens expire after 24 hours
- All file paths are stored relative to the backend directory

## License

ISC
