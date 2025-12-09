import sequelize from '../db.js';
import Uye from './Uye.js';
import Product from './Product.js';
import Favori from './Favori.js';
import History from './History.js';

Uye.hasMany(Favori, { foreignKey: 'UyeID' });
Favori.belongsTo(Uye, { foreignKey: 'UyeID' });

Product.hasMany(Favori, { foreignKey: 'ProductID', sourceKey: 'id' });
Favori.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });

Uye.hasMany(History, { foreignKey: 'UyeID' });
History.belongsTo(Uye, { foreignKey: 'UyeID' });

Product.hasMany(History, { foreignKey: 'ProductID', sourceKey: 'id' });
History.belongsTo(Product, { foreignKey: 'ProductID', targetKey: 'id' });

export { sequelize, Uye, Product, Favori, History };