const { createApp } = require("./app");
const config = require("./config");
const { closePool, initializeDatabase } = require("./db");

async function main() {
  await initializeDatabase();

  const app = createApp();
  const server = app.listen(config.port, () => {
    console.log(JSON.stringify({
      level: "info",
      message: "server_started",
      port: config.port,
      environment: config.nodeEnv,
      timestamp: new Date().toISOString()
    }));
  });

  async function shutdown(signal) {
    console.log(JSON.stringify({
      level: "info",
      message: "shutdown_started",
      signal,
      timestamp: new Date().toISOString()
    }));

    server.close(async () => {
      await closePool();
      process.exit(0);
    });
  }

  process.on("SIGTERM", shutdown);
  process.on("SIGINT", shutdown);
}

main().catch((error) => {
  console.error(JSON.stringify({
    level: "error",
    message: "startup_failed",
    error: error.message,
    stack: config.nodeEnv === "production" ? undefined : error.stack,
    timestamp: new Date().toISOString()
  }));
  process.exit(1);
});
