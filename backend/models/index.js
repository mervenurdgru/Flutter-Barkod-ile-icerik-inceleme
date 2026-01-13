import sequelize from '../db.js';

import Uye from './Uye.js';
import Product from './Product.js';
import Favori from './Favori.js';
import History from './History.js';
import Comment from './Comment.js';
import Report from './Report.js';
import Admin from './Admin.js';

Uye.hasMany(Favori, { foreignKey: 'UyeID' });
Favori.belongsTo(Uye, { foreignKey: 'UyeID' });

// Favori.ProductID -> Product.id
Product.hasMany(Favori, { foreignKey: 'ProductID', sourceKey: 'id' });
Favori.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });


Uye.hasMany(History, { foreignKey: 'UyeID' });
History.belongsTo(Uye, { foreignKey: 'UyeID' });

// History.ProductID -> Product.id
Product.hasMany(History, { foreignKey: 'ProductID', sourceKey: 'id' });
History.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });


Uye.hasMany(Comment, { foreignKey: 'UyeID' });
Comment.belongsTo(Uye, { foreignKey: 'UyeID' });

// Comment.ProductID -> Product.id
Product.hasMany(Comment, { foreignKey: 'ProductID', sourceKey: 'id' });
Comment.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });


Uye.hasMany(Report, { foreignKey: 'UyeID' });
Report.belongsTo(Uye, { foreignKey: 'UyeID' });

// Report.ProductID -> Product.id
Product.hasMany(Report, { foreignKey: 'ProductID', sourceKey: 'id' });
Report.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });

export { sequelize, Uye, Product, Favori, History, Comment, Report, Admin };
