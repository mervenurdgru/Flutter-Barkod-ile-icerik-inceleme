import { DataTypes } from 'sequelize';
import sequelize from '../db.js';
import Product from './Product.js';
import Uye from './Uye.js';

const Report = sequelize.define('Report', {
  ReportID: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  Aciklama: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  Durum: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'Bekliyor'
  },
  Tarih: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

Uye.hasMany(Report, { foreignKey: 'UyeID' });
Report.belongsTo(Uye, { foreignKey: 'UyeID' });

Product.hasMany(Report, { foreignKey: 'ProductID' });
Report.belongsTo(Product, { foreignKey: 'ProductID' });

export default Report;
