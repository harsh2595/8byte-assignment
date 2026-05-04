const assert = require("node:assert/strict");
const { test } = require("node:test");
const {
  buildHealthResponse,
  buildReadyResponse,
  parseTodoTitle
} = require("../src/handlers");

test("health response includes service status", () => {
  const body = buildHealthResponse({
    serviceName: "8byte-sample-api",
    version: "test"
  });

  assert.deepEqual(body, {
    status: "ok",
    service: "8byte-sample-api",
    version: "test"
  });
});

test("readiness response succeeds when database check passes", async () => {
  const response = await buildReadyResponse(async () => ({
    configured: true,
    healthy: true
  }));

  assert.equal(response.statusCode, 200);
  assert.equal(response.body.status, "ready");
  assert.equal(response.body.database.healthy, true);
});

test("readiness response returns 503 when database check fails", async () => {
  const response = await buildReadyResponse(async () => {
    throw new Error("connection failed");
  });

  assert.equal(response.statusCode, 503);
  assert.equal(response.body.status, "not_ready");
  assert.equal(response.body.database.healthy, false);
  assert.equal(response.body.message, "connection failed");
});

test("todo title parser trims user input", () => {
  assert.equal(parseTodoTitle({ title: "  ship platform  " }), "ship platform");
  assert.equal(parseTodoTitle({}), "");
});
