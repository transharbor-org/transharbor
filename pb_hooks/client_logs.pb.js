// pb_hooks/client_logs.pb.js
// Handle client-side logs from Flutter app and forward to stdout (Loki picks up via Promtail)

onRecordBeforeCreateRequest((e) => {
  const data = e.httpContext.request().json();
  
  if (!data.logs || !Array.isArray(data.logs)) {
    throw new BadRequestError('Invalid log format');
  }

  // Log each entry to stdout in JSON format for Loki
  data.logs.forEach(log => {
    const logEntry = {
      level: log.level || 'info',
      message: log.message,
      timestamp: log.timestamp || new Date().toISOString(),
      source: 'flutter_client',
      userId: log.userId,
      screen: log.screen,
      metadata: log.metadata,
      stackTrace: log.stackTrace,
    };

    // Output as JSON for structured logging
    console.log(JSON.stringify(logEntry));
  });

  // Don't actually store in database - just acknowledge receipt
  e.httpContext.response().writeHeader(200);
  e.httpContext.response().write(JSON.stringify({ success: true, count: data.logs.length }));
  
  // Prevent default database insertion
  return e.httpContext.response().end();
}, "client_logs");
