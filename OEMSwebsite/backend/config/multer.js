const multer = require('multer');
const path = require('path');
const fs = require('fs');

const isVercel = process.env.VERCEL === '1';
const baseUploadPath = isVercel ? '/tmp' : path.join(__dirname, '..');

// Create uploads directory if it doesn't exist
const uploadDir = path.join(baseUploadPath, process.env.UPLOAD_DIR || 'uploads');
const expenseUploadDir = path.join(uploadDir, 'expenses');
const expansionUploadDir = path.join(uploadDir, 'expansion-funds');
const chequeUploadDir = path.join(uploadDir, 'cheques');

[uploadDir, expenseUploadDir, expansionUploadDir, chequeUploadDir].forEach(dir => {
  try {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  } catch (err) {
    console.warn(`Could not create directory ${dir}:`, err.message);
  }
});

// Configure storage for expense documents
const expenseStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, expenseUploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'expense-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Configure storage for expansion fund documents
const expansionStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, expansionUploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'expansion-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Configure storage for cheques
const chequeStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, chequeUploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'cheque-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only PDF, JPG, and PNG files are allowed.'), false);
  }
};

// Multer configuration
const expenseUpload = multer({
  storage: expenseStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB default
  }
});

const expansionUpload = multer({
  storage: expansionStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB default
  }
});

const chequeUpload = multer({
  storage: chequeStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB default
  }
});

module.exports = {
  expenseUpload,
  expansionUpload,
  chequeUpload,
  expenseUploadDir,
  expansionUploadDir,
  chequeUploadDir
};
