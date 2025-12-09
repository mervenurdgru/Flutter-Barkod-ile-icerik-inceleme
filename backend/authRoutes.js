// authRoutes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const sql = require('mssql');
require('dotenv').config();

// Kullanıcı girişi
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const pool = await sql.connect(process.env.MSSQL_STRING);
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE email = @email');

    const user = result.recordset[0];
    if (!user) return res.status(400).json({ message: 'Kullanıcı bulunamadı' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Şifre yanlış' });

    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({ token, user: { id: user.id, email: user.email, username: user.username } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

module.exports = router;

router.get('/users/:userId/favorites', async (req, res) => {
  const userId = req.params.userId;
  try {
    const pool = await sql.connect(process.env.MSSQL_STRING);
    const result = await pool.request()
      .input('userId', sql.Int, userId)
      .query('SELECT * FROM Favorites WHERE userId = @userId');
    res.json(result.recordset);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});
