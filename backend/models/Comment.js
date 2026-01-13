import { DataTypes } from 'sequelize';
import sequelize from '../db.js';
import Product from './Product.js';
import Uye from './Uye.js';

const Comment = sequelize.define('Comment', {
  CommentID: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  YorumMetni: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  Puan: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  YorumTarihi: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
});

Uye.hasMany(Comment, { foreignKey: 'UyeID' });
Comment.belongsTo(Uye, { foreignKey: 'UyeID' });

Product.hasMany(Comment, { foreignKey: 'ProductID' });
Comment.belongsTo(Product, { foreignKey: 'ProductID' });

export default Comment;
