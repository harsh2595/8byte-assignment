function buildHealthResponse(config) {
  return {
    status: "ok",
    service: config.serviceName,
    version: config.version
  };
}

async function buildReadyResponse(checkDatabase) {
  try {
    const database = await checkDatabase();

    return {
      statusCode: 200,
      body: {
        status: "ready",
        database
      }
    };
  } catch (error) {
    return {
      statusCode: 503,
      body: {
        status: "not_ready",
        database: {
          configured: true,
          healthy: false
        },
        message: error.message
      }
    };
  }
}

function parseTodoTitle(body) {
  return String(body?.title || "").trim();
}

module.exports = {
  buildHealthResponse,
  buildReadyResponse,
  parseTodoTitle
};
