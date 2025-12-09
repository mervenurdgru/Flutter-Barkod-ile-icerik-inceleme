import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  productName: {
    type: DataTypes.STRING
  },
  barcode: {
    type: DataTypes.STRING,
    unique: true
  },
  Icindekiler: {
    type: DataTypes.TEXT, 
    allowNull: true 
  },
  AlerjenUyarisi: {
    type: DataTypes.TEXT, 
    allowNull: true 
  },
  Description: { 
    type: DataTypes.TEXT 
  },
  Origin: { 
    type: DataTypes.STRING
  },
  ImageUrl: {
    type: DataTypes.STRING
  },
  Nutrients: { 
    type: DataTypes.TEXT
  }
}, {
  tableName: 'Products',
  timestamps: false
});

export default Product;