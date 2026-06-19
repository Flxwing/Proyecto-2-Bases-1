const sql = require('mssql');
require('dotenv').config();

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER || 'Desktop_Alonso',
  database: process.env.DB_DATABASE || 'BD_AgroveterinariaLaYunta',
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_CERT === 'true'
  }
};

if (process.env.DB_PORT) {
  config.port = parseInt(process.env.DB_PORT, 10);
}

let pool;

async function getPool() {
  if (!pool) {
    pool = await sql.connect(config);
  }

  return pool;
}

module.exports = {
  sql,
  getPool
};