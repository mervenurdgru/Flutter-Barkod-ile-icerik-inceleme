import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Uye = sequelize.define('Uye', {
  UyeID: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
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
  Email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  KayitTarihi: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'Uyeler', 
  timestamps: false
});

export default Uye;