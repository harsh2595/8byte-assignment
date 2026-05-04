const config = {
  serviceName: process.env.SERVICE_NAME || "8byte-sample-api",
  version: process.env.APP_VERSION || process.env.GITHUB_SHA || "local",
  port: Number(process.env.PORT || 4000),
  nodeEnv: process.env.NODE_ENV || "development",
  databaseUrl: process.env.DATABASE_URL,
  dbHost: process.env.DB_HOST,
  dbPort: Number(process.env.DB_PORT || 5432),
  dbName: process.env.DB_NAME,
  dbUser: process.env.DB_USER,
  dbPassword: process.env.DB_PASSWORD,
  dbSsl: String(process.env.DB_SSL || "false").toLowerCase() === "true"
};

config.hasDatabaseConfig = Boolean(
  config.databaseUrl || (config.dbHost && config.dbName && config.dbUser)
);

module.exports = config;
