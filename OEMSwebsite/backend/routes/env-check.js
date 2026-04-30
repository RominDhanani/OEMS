const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    DB_HOST: process.env.DB_HOST ? `${process.env.DB_HOST.substring(0, 5)}...` : 'MISSING',
    DB_USER: process.env.DB_USER ? 'PRESENT' : 'MISSING',
    DB_PORT: process.env.DB_PORT || 'DEFAULT',
    SSL_MODE: process.env.SSL_MODE || 'DEFAULT',
    NODE_ENV: process.env.NODE_ENV,
    VERCEL: process.env.VERCEL
  });
});

module.exports = router;
