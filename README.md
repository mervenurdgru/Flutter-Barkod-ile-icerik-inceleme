# 📱 Barkod ile Ürün İnceleme Uygulaması

Bu proje, kullanıcıların yiyecek ve içecek ürünlerinin barkodlarını tarayarak veya manuel girerek; içerik bilgilerini, alerjen uyarılarını, besin değerlerini ve menşei bilgilerini görüntülemesini sağlayan tam kapsamlı bir mobil uygulamadır.

## 🚀 Özellikler

* **🔐 Kullanıcı İşlemleri:** Kayıt Ol (Register) ve Giriş Yap (Login) özellikleri (JWT Authentication ile güvenli oturum).
* **📸 Barkod Tarama:** Cihaz kamerasını kullanarak hızlı barkod okuma (Mobile Scanner).
* **⌨️ Manuel Sorgulama:** Kamera kullanılamayan durumlar veya silik barkodlar için manuel numara girişi.
* **📝 Ürün Detayları:** Taranan ürünün içindekiler, alerjenler, besin değerleri ve menşei bilgilerini detaylı görüntüleme.
* **❤️ Favoriler:** Beğenilen ürünleri favori listesine ekleme ve çıkarma.
* **🕒 Geçmiş:** Daha önce taranan ürünlerin otomatik olarak geçmişe kaydedilmesi ve listelenmesi.
* **🍔 Yan Menü (Drawer):** Kolay navigasyon için modern yan menü tasarımı.

## 🛠️ Kullanılan Teknolojiler

### Frontend (Mobil Uygulama)
* **Framework:** Flutter (Dart)
* **Http İstemcisi:** Dio
* **Depolama:** Flutter Secure Storage (Token yönetimi için)
* **Barkod Okuma:** Mobile Scanner
* **Arayüz:** Material Design 3

### Backend (API Sunucusu)
* **Runtime:** Node.js
* **Framework:** Express.js
* **Veritabanı:** Microsoft SQL Server (MSSQL)
* **ORM:** Sequelize
* **Kimlik Doğrulama:** JSON Web Token (JWT) & Bcryptjs
