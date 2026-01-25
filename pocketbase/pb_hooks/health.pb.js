/// <reference path="../pb_data/types.d.ts" />

/**
 * Custom health endpoint with version information
 * Extends the default /api/health endpoint to include deployment metadata
 */

// Read version from environment or use build timestamp
const APP_VERSION = $os.getenv('APP_VERSION') || 'unknown';
const BUILD_TIME = $os.getenv('BUILD_TIME') || new Date().toISOString();
const GIT_SHA = $os.getenv('GIT_SHA') || 'unknown';

onBeforeServe((e) => {
  // Custom health endpoint with version info
  e.router.get('/api/health/version', (c) => {
    return c.json(200, {
      status: 'healthy',
      version: APP_VERSION,
      gitSha: GIT_SHA,
      buildTime: BUILD_TIME,
      timestamp: new Date().toISOString(),
      pocketbaseVersion: '0.18.10'
    });
  });

  // Override default health endpoint to include version
  e.router.get('/api/health', (c) => {
    return c.json(200, {
      code: 200,
      message: 'API is healthy.',
      data: {
        version: APP_VERSION,
        gitSha: GIT_SHA
      }
    });
  });
});
