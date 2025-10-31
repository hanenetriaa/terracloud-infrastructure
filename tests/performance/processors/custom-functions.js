/**
 * Custom Artillery Processor Functions
 * TerraCloud Performance Testing
 *
 * This file contains custom functions for Artillery test scenarios
 * including data generation, custom logging, and test flow control.
 */

module.exports = {
  // Called before the test run starts
  beforeScenario: beforeScenario,
  afterScenario: afterScenario,

  // Custom functions available in test scenarios
  generateRandomUser: generateRandomUser,
  generateTestPayload: generateTestPayload,
  logCustomMetric: logCustomMetric,
  setCustomData: setCustomData
};

/**
 * Initialize scenario-specific data before scenario execution
 * @param {Object} context - Artillery context object
 * @param {Object} events - Event emitter
 * @param {Function} done - Callback function
 */
function beforeScenario(context, events, done) {
  // Set custom variables for this virtual user
  context.vars.startTime = Date.now();
  context.vars.sessionId = generateSessionId();
  context.vars.testRunId = process.env.TEST_RUN_ID || 'default-run';

  // Log scenario start (optional, can be verbose)
  // console.log(`[${new Date().toISOString()}] Starting scenario for session: ${context.vars.sessionId}`);

  return done();
}

/**
 * Cleanup and logging after scenario completes
 * @param {Object} context - Artillery context object
 * @param {Object} events - Event emitter
 * @param {Function} done - Callback function
 */
function afterScenario(context, events, done) {
  const duration = Date.now() - context.vars.startTime;

  // Log completion
  // console.log(`[${new Date().toISOString()}] Scenario completed in ${duration}ms for session: ${context.vars.sessionId}`);

  // Emit custom metric (visible in Artillery report)
  events.emit('counter', 'scenarios.completed', 1);
  events.emit('histogram', 'scenarios.duration', duration);

  return done();
}

/**
 * Generate a random user object
 * @param {Object} context - Artillery context
 * @param {Object} events - Event emitter
 * @param {Function} next - Callback
 */
function generateRandomUser(context, events, next) {
  context.vars.randomUser = {
    id: `user_${Math.floor(Math.random() * 100000)}`,
    email: `test${Math.floor(Math.random() * 10000)}@example.com`,
    name: `TestUser${Math.floor(Math.random() * 1000)}`,
    timestamp: new Date().toISOString()
  };

  return next();
}

/**
 * Generate test payload with random data
 * @param {Object} context - Artillery context
 * @param {Object} events - Event emitter
 * @param {Function} next - Callback
 */
function generateTestPayload(context, events, next) {
  context.vars.testPayload = {
    requestId: generateRequestId(),
    sessionId: context.vars.sessionId,
    timestamp: new Date().toISOString(),
    testType: context.vars.testType || 'unknown',
    infrastructure: process.env.INFRASTRUCTURE_TYPE || 'unknown',
    data: {
      randomValue: Math.random(),
      randomInt: Math.floor(Math.random() * 1000),
      randomString: generateRandomString(10)
    }
  };

  return next();
}

/**
 * Log custom metrics for analysis
 * @param {Object} context - Artillery context
 * @param {Object} events - Event emitter
 * @param {Function} next - Callback
 */
function logCustomMetric(context, events, next) {
  // Emit custom metrics
  if (context.vars.customMetricName && context.vars.customMetricValue) {
    events.emit('counter', context.vars.customMetricName, context.vars.customMetricValue);
  }

  return next();
}

/**
 * Set custom data on context for use in subsequent requests
 * @param {Object} context - Artillery context
 * @param {Object} events - Event emitter
 * @param {Function} next - Callback
 */
function setCustomData(context, events, next) {
  // Add any custom data processing here
  context.vars.processingTime = Date.now();
  context.vars.requestCount = (context.vars.requestCount || 0) + 1;

  return next();
}

// Helper functions

/**
 * Generate a unique session ID
 * @returns {string} Session ID
 */
function generateSessionId() {
  return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Generate a unique request ID
 * @returns {string} Request ID
 */
function generateRequestId() {
  return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Generate a random string of specified length
 * @param {number} length - Desired string length
 * @returns {string} Random string
 */
function generateRandomString(length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Custom response handler example
 * Can be used to validate responses or extract specific data
 */
function customResponseHandler(requestParams, response, context, ee, next) {
  // Log response time
  const responseTime = Date.now() - context.vars._requestStartTime;

  // Emit custom metric
  ee.emit('histogram', 'custom.response_time', responseTime);

  // Check for specific conditions
  if (response.statusCode >= 500) {
    ee.emit('counter', 'custom.server_errors', 1);
  } else if (response.statusCode >= 400) {
    ee.emit('counter', 'custom.client_errors', 1);
  } else if (response.statusCode >= 200 && response.statusCode < 300) {
    ee.emit('counter', 'custom.successful_requests', 1);
  }

  return next();
}

/**
 * Error handler for failed requests
 */
function handleError(error, context, ee, next) {
  console.error(`Request failed: ${error.message}`);
  ee.emit('counter', 'custom.request_failures', 1);
  return next();
}

// Export additional utility functions if needed
module.exports.customResponseHandler = customResponseHandler;
module.exports.handleError = handleError;
