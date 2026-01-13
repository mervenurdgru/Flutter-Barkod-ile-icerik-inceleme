import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import Admin from './models/Admin.js';
import Comment from './models/Comment.js';

import { sequelize, Uye, Product, Favori, History, Report } from './models/index.js';

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET =
  process.env.JWT_SECRET || 'bu-cok-gizli-bir-anahtar-kimse-bilmemeli-123456';

// ===================== DB SYNC =====================
(async () => {
  try {
    await sequelize.sync();
    console.log('✅ Veritabanı ve modeller senkronize edildi.');
  } catch (err) {
    console.error('❌ Senkronizasyon hatası:', err.message || err);
  }
})();

// ===================== AUTH MIDDLEWARE =====================
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token eksik' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Token geçersiz' });
    req.user = user;
    next();
  });
}

function adminAuthenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token eksik' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err || user.rol !== 'admin') {
      return res.status(403).json({ message: 'Geçersiz veya yetkisiz token' });
    }
    req.admin = user;
    next();
  });
}

// ===================== USERS =====================

// Kullanıcı Kayıt
app.post('/api/users/register', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre, Email } = req.body;
    if (!KullaniciAdi || !Sifre || !Email) {
      return res.status(400).json({ message: 'Eksik alanlar' });
    }

    const check = await Uye.findOne({ where: { KullaniciAdi } });
    if (check) return res.status(400).json({ message: 'Kullanıcı adı mevcut' });

    const hashed = await bcrypt.hash(Sifre, 10);
    const newUser = await Uye.create({
      KullaniciAdi,
      Sifre: hashed,
      Email,
      KayitTarihi: new Date(),
    });

    const token = jwt.sign({ id: newUser.UyeID, KullaniciAdi }, JWT_SECRET, {
      expiresIn: '1d',
    });

    res.status(201).json({ token });
  } catch (err) {
    console.error('Kayıt Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Kullanıcı Giriş
app.post('/api/users/login', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre } = req.body;

    const user = await Uye.findOne({ where: { KullaniciAdi } });
    if (!user) return res.status(400).json({ message: 'Kullanıcı yok' });

    const match = await bcrypt.compare(Sifre, user.Sifre);
    if (!match) return res.status(400).json({ message: 'Şifre yanlış' });

    const token = jwt.sign({ id: user.UyeID, KullaniciAdi }, JWT_SECRET, {
      expiresIn: '1d',
    });

    res.json({ token });
  } catch (err) {
    console.error('Giriş Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== ADMIN AUTH =====================

// Admin Kayıt (geliştirme için)
app.post('/api/admin/register', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre } = req.body;
    if (!KullaniciAdi || !Sifre) {
      return res.status(400).json({ message: 'Eksik alanlar' });
    }

    const existing = await Admin.findOne({ where: { KullaniciAdi } });
    if (existing) return res.status(400).json({ message: 'Bu admin zaten mevcut' });

    const hashed = await bcrypt.hash(Sifre, 10);
    const newAdmin = await Admin.create({ KullaniciAdi, Sifre: hashed });

    const token = jwt.sign(
      { id: newAdmin.AdminID, KullaniciAdi: newAdmin.KullaniciAdi, rol: 'admin' },
      JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.status(201).json({ message: 'Admin oluşturuldu', token });
  } catch (err) {
    console.error('Admin register hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin Giriş
app.post('/api/admin/login', async (req, res) => {
  try {
    const { KullaniciAdi, Sifre } = req.body;

    const admin = await Admin.findOne({ where: { KullaniciAdi } });
    if (!admin) return res.status(404).json({ message: 'Admin bulunamadı' });

    const match = await bcrypt.compare(Sifre, admin.Sifre);
    if (!match) return res.status(401).json({ message: 'Şifre yanlış' });

    const token = jwt.sign(
      { id: admin.AdminID, KullaniciAdi: admin.KullaniciAdi, rol: 'admin' },
      JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({ token });
  } catch (err) {
    console.error('Admin login hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== PRODUCTS (PUBLIC) =====================

// Ürün Barkod Sorgulama
app.get('/api/products/:barkod', async (req, res) => {
  try {
    const { barkod } = req.params;
    const urun = await Product.findOne({ where: { barcode: barkod } });
    if (!urun) return res.status(404).json({ message: 'Ürün bulunamadı.' });

    res.json({ urun });
  } catch (err) {
    console.error('Ürün Sorgu Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== FAVORITES / HISTORY =====================

// Favori Ekle
app.post('/api/users/favorites/add', authenticateToken, async (req, res) => {
  try {
    const { ProductID } = req.body;
    const UyeID = req.user.id;

    const [favori, created] = await Favori.findOrCreate({
      where: { UyeID, ProductID },
    });

    if (created) return res.json({ message: 'Favori eklendi' });
    return res.status(400).json({ message: 'Zaten favoride' });
  } catch (err) {
    console.error('Favori Ekleme Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Favori Listele
app.get('/api/users/favorites', authenticateToken, async (req, res) => {
  try {
    const result = await Favori.findAll({
      where: { UyeID: req.user.id },
      attributes: ['ProductID'],
      include: {
        model: Product,
        attributes: [['productName', 'ProductName']],
      },
    });

    const flatResult = result.map((f) => ({
      ProductID: f.ProductID,
      ProductName: f.Product ? f.Product.dataValues.ProductName : 'Silinmiş Ürün',
    }));

    res.json(flatResult);
  } catch (err) {
    console.error('Favori Getirme Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Favori Sil
app.post('/api/users/favorites/remove', authenticateToken, async (req, res) => {
  try {
    const { ProductID } = req.body;
    const UyeID = req.user.id;

    const deleted = await Favori.destroy({ where: { UyeID, ProductID } });
    if (deleted) return res.json({ message: 'Favorilerden çıkarıldı' });

    res.status(404).json({ message: 'Favori bulunamadı' });
  } catch (err) {
    console.error('Favori Silme Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Geçmişe Ekle
app.post('/api/users/history/add', authenticateToken, async (req, res) => {
  try {
    const { ProductID, Barkod } = req.body;
    const UyeID = req.user.id;

    await History.create({
      UyeID,
      ProductID,
      Barkod,
      TaramaTarihi: new Date(),
    });

    res.json({ message: 'Geçmişe kaydedildi' });
  } catch (err) {
    console.error('Geçmiş Ekleme Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Geçmiş Listele
app.get('/api/users/history', authenticateToken, async (req, res) => {
  try {
    const result = await History.findAll({
      where: { UyeID: req.user.id },
      attributes: ['ProductID', 'Barkod', 'TaramaTarihi'],
      include: {
        model: Product,
        attributes: [['productName', 'ProductName']],
      },
      order: [['TaramaTarihi', 'DESC']],
    });

    const flatResult = result.map((h) => ({
      ProductID: h.ProductID,
      ProductName: h.Product ? h.Product.dataValues.ProductName : 'Silinmiş Ürün',
      Barkod: h.Barkod,
      TaramaTarihi: h.TaramaTarihi,
    }));

    res.json(flatResult);
  } catch (err) {
    console.error('Geçmiş Getirme Hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== ADMIN PRODUCTS =====================

// Admin: Ürünleri Listele
app.get('/api/admin/products', adminAuthenticateToken, async (req, res) => {
  try {
    const products = await Product.findAll({
      attributes: [
        'id',
        'productName',
        'barcode',
        'Description',
        'Icindekiler',
        'AlerjenUyarisi',
        'ImageUrl',
      ],
      order: [['id', 'DESC']],
    });
    res.json(products);
  } catch (err) {
    console.error('Admin ürün listeleme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Ürün Ekle
app.post('/api/admin/products/add', adminAuthenticateToken, async (req, res) => {
  try {
    let { productName, barcode, description, Icindekiler, AlerjenUyarisi, ImageUrl } = req.body;

    productName = (productName ?? '').trim();
    barcode = (barcode ?? '').trim();

    if (!productName || !barcode) {
      return res.status(400).json({ message: 'Ürün adı ve barkod zorunludur' });
    }

    if (!/^\d{8,14}$/.test(barcode)) {
      return res.status(400).json({ message: 'Barkod 8-14 haneli sayısal olmalı' });
    }

    const existing = await Product.findOne({ where: { barcode } });
    if (existing) return res.status(400).json({ message: 'Bu barkod zaten mevcut' });

    const newProduct = await Product.create({
      productName,
      barcode,
      Description: (description ?? '').trim() || null,
      Icindekiler: (Icindekiler ?? '').trim() || null,
      AlerjenUyarisi: (AlerjenUyarisi ?? '').trim() || null,
      ImageUrl: (ImageUrl ?? '').trim() || null,
    });

    res.status(201).json({ message: 'Ürün eklendi', product: newProduct });
  } catch (err) {
    console.error('Admin ürün ekleme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Ürün Güncelle
app.put('/api/admin/products/update/:id', adminAuthenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    let { productName, barcode, description, Icindekiler, AlerjenUyarisi, ImageUrl } = req.body;

    productName = (productName ?? '').trim();
    barcode = (barcode ?? '').trim();

    if (!productName || !barcode) {
      return res.status(400).json({ message: 'Ürün adı ve barkod zorunludur' });
    }

    if (!/^\d{8,14}$/.test(barcode)) {
      return res.status(400).json({ message: 'Barkod 8-14 haneli sayısal olmalı' });
    }

    // Barkod başkasında var mı?
    const existing = await Product.findOne({ where: { barcode } });
    if (existing && String(existing.id) !== String(id)) {
      return res.status(400).json({ message: 'Bu barkod başka bir üründe kayıtlı' });
    }

    const [affected] = await Product.update(
      {
        productName,
        barcode,
        Description: (description ?? '').trim() || null,
        Icindekiler: (Icindekiler ?? '').trim() || null,
        AlerjenUyarisi: (AlerjenUyarisi ?? '').trim() || null,
        ImageUrl: (ImageUrl ?? '').trim() || null,
      },
      { where: { id } }
    );

    if (affected === 0) return res.status(404).json({ message: 'Ürün bulunamadı' });

    res.json({ message: 'Ürün güncellendi' });
  } catch (err) {
    console.error('Admin ürün güncelleme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Ürün Sil
app.delete('/api/admin/products/delete/:id', adminAuthenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Product.destroy({ where: { id } });
    if (!deleted) return res.status(404).json({ message: 'Ürün bulunamadı' });

    res.json({ message: 'Ürün silindi' });
  } catch (err) {
    console.error('Admin ürün silme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== ADMIN REPORTS =====================

// Admin: Raporları Listele
app.get('/api/admin/reports', adminAuthenticateToken, async (req, res) => {
  try {
    const reports = await Report.findAll({
      include: [
        { model: Uye, attributes: ['KullaniciAdi'] },
        { model: Product, attributes: ['productName'] },
      ],
      order: [['Tarih', 'DESC']],
    });

    const response = reports.map((report) => ({
      ReportID: report.ReportID,
      Aciklama: report.Aciklama,
      Durum: report.Durum,
      Tarih: report.Tarih,
      KullaniciAdi: report.Uye?.KullaniciAdi || 'Silinmiş Kullanıcı',
      ProductName: report.Product?.productName || 'Silinmiş Ürün',
    }));

    res.json(response);
  } catch (err) {
    console.error('Rapor listeleme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Rapor Sil
app.delete('/api/admin/reports/:id', adminAuthenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Report.destroy({ where: { ReportID: id } });
    if (!deleted) return res.status(404).json({ message: 'Rapor bulunamadı' });

    res.json({ message: 'Rapor silindi' });
  } catch (err) {
    console.error('Rapor silme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Rapor Durum Güncelle
app.put('/api/admin/reports/:id/status', adminAuthenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { Durum } = req.body;

    const allowed = ['Beklemede', 'İnceleniyor', 'Çözüldü', 'Reddedildi'];
    if (!Durum || !allowed.includes(Durum)) {
      return res.status(400).json({ message: `Durum geçersiz. İzinli: ${allowed.join(', ')}` });
    }

    const [affected] = await Report.update(
      { Durum },
      { where: { ReportID: id } }
    );

    if (affected === 0) return res.status(404).json({ message: 'Rapor bulunamadı' });

    res.json({ message: 'Rapor durumu güncellendi' });
  } catch (err) {
    console.error('Rapor durum güncelleme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== ADMIN COMMENTS =====================

// Admin: Yorumları Listele
app.get('/api/admin/comments', adminAuthenticateToken, async (req, res) => {
  try {
    const comments = await Comment.findAll({
      include: [
        { model: Uye, attributes: ['KullaniciAdi'] },
        { model: Product, attributes: ['productName'] },
      ],
      order: [['YorumTarihi', 'DESC']],
    });

    const result = comments.map((comment) => ({
      CommentID: comment.CommentID,
      YorumMetni: comment.YorumMetni,
      Puan: comment.Puan,
      YorumTarihi: comment.YorumTarihi,
      KullaniciAdi: comment.Uye?.KullaniciAdi || 'Silinmiş Kullanıcı',
      ProductName: comment.Product?.productName || 'Silinmiş Ürün',
    }));

    res.json(result);
  } catch (err) {
    console.error('Yorumları getirme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// Admin: Yorum Sil
app.delete('/api/admin/comments/:id', adminAuthenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Comment.destroy({ where: { CommentID: id } });
    if (!deleted) return res.status(404).json({ message: 'Yorum bulunamadı' });

    res.json({ message: 'Yorum silindi' });
  } catch (err) {
    console.error('Yorum silme hatası:', err.message || err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// ===================== START =====================
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend ${PORT} portunda çalışıyor (Ağa Açık)`);
});
