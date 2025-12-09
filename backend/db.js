import { Sequelize } from 'sequelize';
import 'dotenv/config';

const {
  DB_HOST,
  DB_SERVER, 
  DB_NAME,
  DB_USER,
  DB_PASS,
  DB_PORT,
  DB_INSTANCE,
  DB_TRUSTED 
} = process.env;

function createSequelize() {

  const serverRaw = DB_HOST || DB_SERVER || undefined;

  const explicitTrusted = DB_TRUSTED === 'true' || DB_TRUSTED === '1';
  const implicitTrusted = !DB_USER && !DB_PASS && !!serverRaw;
  const trusted = explicitTrusted || implicitTrusted;

  if (!trusted && (!DB_USER || !DB_PASS)) {
    console.error('\nVeritabanı kullanıcı adı/şifresi bulunamadı. Lütfen .env veya ortam değişkenlerini ayarlayın:');
    console.error('   - DB_USER (kullanıcı adı)');
    console.error('   - DB_PASS (şifre)');
    console.error('   - DB_HOST or DB_SERVER (sunucu)');
    console.error('   - DB_NAME (veritabanı adı)\n');
    process.exit(1);
  }

  const baseOptions = {
    dialect: 'mssql',
    logging: false,
    dialectOptions: {
      options: {
        encrypt: true,
        trustServerCertificate: true,
      }
    }
  };

  if (trusted) {
    console.log('Trusted (Windows) connection mode selected. Will attempt integrated auth using msnodesqlv8 if available.');

    let host = serverRaw || 'localhost';
    let instanceName = DB_INSTANCE;
    if (serverRaw && serverRaw.includes('\\')) {
      const parts = serverRaw.split('\\');
      host = parts[0];
      instanceName = parts[1] || instanceName;
    }

    const serverPart = instanceName ? `${host}\\${instanceName}` : host;
    const driver = '{SQL Server Native Client 11.0}';
    const connectionString = `Driver=${driver};Server=${serverPart};Database=${DB_NAME || 'master'};Trusted_Connection=Yes;`;

    return new Sequelize(DB_NAME || 'master', null, null, {
      dialect: 'mssql',
      logging: false,
      dialectModulePath: 'msnodesqlv8',
      dialectOptions: {
        connectionString,
        options: {
          encrypt: true,
          trustServerCertificate: true
        }
      }
    });
  }

  return new Sequelize(DB_NAME, DB_USER, DB_PASS, {
    host: DB_HOST || DB_SERVER || 'localhost',
    port: DB_PORT ? parseInt(DB_PORT, 10) : 1433,
    ...baseOptions
  });
}

const sequelize = createSequelize();

(async () => {
  try {
    await sequelize.authenticate();
    console.log('Sequelize ile veritabanı bağlantısı başarılı.');
  } catch (error) {
    const msg = error && error.message ? error.message : String(error);
    console.error('Sequelize bağlantı hatası:', msg);

    const code = (error && (error.parent || error.original) && (error.parent || error.original).code) || error.code;
    if (code === 'ELOGIN' || /Login failed for user ''/.test(msg)) {
      console.error('\nHata tespit edildi: SQL Login başarısız. ');
      console.error('Çözüm seçenekleri:');
      console.error('  1) SQL Authentication kullanın: .env içine DB_USER ve DB_PASS ekleyin (ve DB_HOST/DB_NAME doldurun).');
      console.error('  2) Integrated auth kullanmak istiyorsanız, Windows için ek yapılandırma gerekir (ör. msnodesqlv8 sürücüsü veya uygun tedious ntlm/sspi ayarları). Ben bu konuda yardımcı olabilirim.');
      console.error('  3) Veya local geliştirme için sqlite gibi bir fallback kullanabilirsiniz.');
    }

    console.error(error);
    process.exit(1);
  }
})();

export default sequelize;