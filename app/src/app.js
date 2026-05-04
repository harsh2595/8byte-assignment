const express = require("express");
const promClient = require("prom-client");
const config = require("./config");
const { checkDatabase, query } = require("./db");
const { buildHealthResponse, buildReadyResponse, parseTodoTitle } = require("./handlers");

function createApp() {
  const app = express();
  const registry = new promClient.Registry();

  registry.setDefaultLabels({
    service: config.serviceName,
    environment: config.nodeEnv
  });

  promClient.collectDefaultMetrics({ register: registry });

  const requestDuration = new promClient.Histogram({
    name: "http_request_duration_seconds",
    help: "HTTP request duration in seconds",
    labelNames: ["method", "route", "status_code"],
    buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
    registers: [registry]
  });

  const requestCount = new promClient.Counter({
    name: "http_requests_total",
    help: "Total HTTP requests",
    labelNames: ["method", "route", "status_code"],
    registers: [registry]
  });

  app.use(express.json());

  app.use((req, res, next) => {
    const start = process.hrtime.bigint();

    res.on("finish", () => {
      const route = req.route?.path || req.path;
      const labels = {
        method: req.method,
        route,
        status_code: String(res.statusCode)
      };
      const duration = Number(process.hrtime.bigint() - start) / 1e9;

      requestCount.inc(labels);
      requestDuration.observe(labels, duration);

      console.log(JSON.stringify({
        level: res.statusCode >= 500 ? "error" : "info",
        method: req.method,
        path: req.path,
        statusCode: res.statusCode,
        durationMs: Math.round(duration * 1000),
        timestamp: new Date().toISOString()
      }));
    });

    next();
  });

  app.get("/health", (_req, res) => {
    res.json(buildHealthResponse(config));
  });

  app.get("/ready", async (_req, res) => {
    const readiness = await buildReadyResponse(checkDatabase);
    res.status(readiness.statusCode).json(readiness.body);
  });

  app.get("/metrics", async (_req, res) => {
    res.set("Content-Type", registry.contentType);
    res.end(await registry.metrics());
  });

  app.get("/api/todos", async (_req, res, next) => {
    try {
      const result = await query(
        "SELECT id, title, completed, created_at FROM todos ORDER BY created_at DESC LIMIT 50"
      );

      res.json({
        items: result.rows
      });
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/todos", async (req, res, next) => {
    try {
      const title = parseTodoTitle(req.body);

      if (!title) {
        res.status(400).json({ message: "title is required" });
        return;
      }

      const result = await query(
        "INSERT INTO todos (title) VALUES ($1) RETURNING id, title, completed, created_at",
        [title]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      next(error);
    }
  });

  app.use((error, _req, res, _next) => {
    console.error(JSON.stringify({
      level: "error",
      message: error.message,
      stack: config.nodeEnv === "production" ? undefined : error.stack,
      timestamp: new Date().toISOString()
    }));

    res.status(500).json({
      message: "internal server error"
    });
  });

  return app;
}

module.exports = {
  createApp
};
