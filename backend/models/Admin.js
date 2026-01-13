import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Admin = sequelize.define('Admin', {
  AdminID: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  KullaniciAdi: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  Sifre: {
    type: DataTypes.STRING,
    allowNull: false
  },
  YetkiTuru: {
    type: DataTypes.STRING,
    defaultValue: 'admin'  // veya 'superadmin'
  },
  OlusturmaTarihi: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

export default Admin;
