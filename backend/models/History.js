import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const History = sequelize.define('History', {
  HistoryID: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  UyeID: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  ProductID: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  Barkod: {
    type: DataTypes.STRING
  },
  TaramaTarihi: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'History',
  timestamps: false
});

export default History;