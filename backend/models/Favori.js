import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Favori = sequelize.define('Favori', {
  FavoriID: {
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
  }
}, {
  tableName: 'Favoriler',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['UyeID', 'ProductID']
    }
  ]
});

export default Favori;