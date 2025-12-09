import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import { sequelize, Uye, Product, Favori, History } from './models/index.js';

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'bu-cok-gizli-bir-anahtar-kimse-bilmemeli-123456';

(async () => {
  try {
    await sequelize.sync();
    console.log("✅ Veritabanı ve modeller senkronize edildi.");
  } catch (err) {
    console.error("❌ Senkronizasyon hatası:", err && err.message ? err.message : err);
  }
})();

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: "Token eksik" });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ success: false, message: "Token geçersiz" });
    req.user = user;
    next();
  });
}


app.post('/api/users/register', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre, Email } = req.body;
    if (!KullaniciAdi || !Sifre || !Email) return res.status(400).json({ message: "Eksik alanlar" });

    const check = await Uye.findOne({ where: { KullaniciAdi } });
    if (check) return res.status(400).json({ message: "Kullanıcı adı mevcut" });

    const hashed = await bcrypt.hash(Sifre, 10);
    
    const newUser = await Uye.create({
      KullaniciAdi,
      Sifre: hashed,
      Email,
      KayitTarihi: new Date()
    });

    const token = jwt.sign({ id: newUser.UyeID, KullaniciAdi }, JWT_SECRET, { expiresIn: '1d' });
    res.status(201).json({ token });
  } catch (err) {
    console.error("Kayıt Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

// Giriş Yap
app.post('/api/users/login', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre } = req.body;
    
    const user = await Uye.findOne({ where: { KullaniciAdi } });
    if (!user) return res.status(400).json({ message: "Kullanıcı yok" });

    const match = await bcrypt.compare(Sifre, user.Sifre);
    if (!match) return res.status(400).json({ message: "Şifre yanlış" });

    const token = jwt.sign({ id: user.UyeID, KullaniciAdi }, JWT_SECRET, { expiresIn: '1d' });
    res.json({ token });
  } catch (err) {
    console.error("Giriş Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası" });
  }
});

app.get('/api/products/:barkod', async (req, res) => {
  try {
    const { barkod } = req.params;
    const urun = await Product.findOne({ where: { barcode: barkod } });

    if (!urun)
      return res.status(404).json({ message: "Ürün bulunamadı." });

    res.json({ urun }); 
  } catch (err) {
    console.error("Ürün Sorgu Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

app.post('/api/users/favorites/add', authenticateToken, async (req, res) => {
  try {
    const { ProductID } = req.body;
    const UyeID = req.user.id;

    const [favori, created] = await Favori.findOrCreate({
      where: { UyeID: UyeID, ProductID: ProductID }
    });
    
    if (created) {
      res.json({ message: "Favori eklendi" });
    } else {
      res.status(400).json({ message: "Bu ürün zaten favorilerinizde" });
    }

  } catch (err) {
    console.error("Favori Ekleme Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

app.post('/api/users/history/add', authenticateToken, async (req, res) => {
  try {
    const { ProductID, Barkod } = req.body;
    const UyeID = req.user.id;

    if (!ProductID || !Barkod) {
      return res.status(400).json({ message: "Eksik veri: ProductID veya Barkod" });
    }

    await History.create({
      UyeID,
      ProductID,
      Barkod,
      TaramaTarihi: new Date()
    });

    res.json({ message: "Geçmişe kaydedildi" });
  } catch (err) {
    console.error("Geçmiş Ekleme Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

app.get('/api/users/favorites', authenticateToken, async (req, res) => {
  try {
    const result = await Favori.findAll({
      where: { UyeID: req.user.id },
      attributes: ['ProductID'], 
      include: {
        model: Product,
        attributes: [['productName', 'ProductName']] 
      }
    });

    const flatResult = result.map(f => ({
      ProductID: f.ProductID,
      ProductName: f.Product ? f.Product.dataValues.ProductName : 'Silinmiş Ürün'
    }));

    res.json(flatResult);
  } catch (err) {
    console.error("Favori Getirme Hatası:", err.message);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

app.post('/api/users/favorites/remove', authenticateToken, async (req, res) => {
  try {
    const { ProductID } = req.body;
    const UyeID = req.user.id;

    const deleted = await Favori.destroy({
      where: { UyeID, ProductID }
    });

    if (deleted) {
      res.json({ success: true, message: "Favorilerden çıkarıldı" });
    } else {
      res.status(404).json({ message: "Favori bulunamadı" });
    }
  } catch (err) {
    console.error("Favori Silme Hatası:", err);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

app.get('/api/users/history', authenticateToken, async (req, res) => {
  try {
    const result = await History.findAll({
      where: { UyeID: req.user.id },
      attributes: ['ProductID', 'Barkod', 'TaramaTarihi'], 
      include: {
        model: Product, 
        attributes: [['productName', 'ProductName']] 
      },
      order: [['TaramaTarihi', 'DESC']]
    });

    const flatResult = result.map(h => ({
      ProductID: h.ProductID,
      ProductName: h.Product ? h.Product.dataValues.ProductName : 'Silinmiş Ürün',
      Barkod: h.Barkod,
      TaramaTarihi: h.TaramaTarihi
    }));

    res.json(flatResult);
  } catch (err) {
    console.error("Geçmiş Getirme Hatası:", err.message);
    res.status(500).json({ message: "Sunucu hatası", error: err.message });
  }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Backend ${PORT} portunda çalışıyor (Ağa Açık)`);
});