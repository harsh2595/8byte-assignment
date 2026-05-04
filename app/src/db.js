const { Pool } = require("pg");
const config = require("./config");

let pool;

function buildPoolConfig() {
  const ssl = config.dbSsl ? { rejectUnauthorized: false } : false;

  if (config.databaseUrl) {
    return {
      connectionString: config.databaseUrl,
      ssl
    };
  }

  return {
    host: config.dbHost,
    port: config.dbPort,
    database: config.dbName,
    user: config.dbUser,
    password: config.dbPassword,
    ssl
  };
}

function getPool() {
  if (!config.hasDatabaseConfig) {
    return null;
  }

  if (!pool) {
    pool = new Pool({
      ...buildPoolConfig(),
      max: Number(process.env.DB_POOL_MAX || 10),
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000
    });
  }

  return pool;
}

async function query(text, params = []) {
  const activePool = getPool();

  if (!activePool) {
    throw new Error("Database is not configured");
  }

  return activePool.query(text, params);
}

async function initializeDatabase() {
  if (!config.hasDatabaseConfig) {
    return;
  }

  await query(`
    CREATE TABLE IF NOT EXISTS todos (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

async function checkDatabase() {
  if (!config.hasDatabaseConfig) {
    return { configured: false, healthy: true };
  }

  await query("SELECT 1");
  return { configured: true, healthy: true };
}

async function closePool() {
  if (pool) {
    await pool.end();
    pool = undefined;
  }
}

module.exports = {
  checkDatabase,
  closePool,
  initializeDatabase,
  query
};
