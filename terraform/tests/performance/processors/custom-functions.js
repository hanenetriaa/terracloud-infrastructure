/**
 * Custom Artillery Processor Functions
 * TerraCloud IaaS vs PaaS Performance Testing
 * 
 * This file contains custom functions used in Artillery test scenarios
 * for generating dynamic test data and adding custom logic.
 */

'use strict';

/**
 * Generate a random string of specified length
 * @param {number} length - Length of the string to generate
 * @returns {string} Random alphanumeric string
 */
function randomString(length = 10) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Generate a random number within a range
 * @param {number} min - Minimum value (inclusive)
 * @param {number} max - Maximum value (inclusive)
 * @returns {number} Random number
 */
function randomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * Get current timestamp in ISO format
 * @returns {string} ISO formatted timestamp
 */
function timestamp() {
  return new Date().toISOString();
}

/**
 * Get current Unix timestamp (milliseconds)
 * @returns {number} Unix timestamp
 */
function unixTimestamp() {
  return Date.now();
}

/**
 * Generate a random email address
 * @returns {string} Random email address
 */
function randomEmail() {
  const domains = ['example.com', 'test.com', 'terracloud.local'];
  const username = randomString(8).toLowerCase();
  const domain = domains[Math.floor(Math.random() * domains.length)];
  return `${username}@${domain}`;
}

/**
 * Generate a random UUID v4
 * @returns {string} UUID v4 string
 */
function randomUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Before request hook - can be used to modify request or add logging
 * @param {Object} requestParams - The request parameters
 * @param {Object} context - Artillery context
 * @param {Object} ee - Event emitter
 * @param {Function} next - Callback to continue
 */
function beforeRequest(requestParams, context, ee, next) {
  // Add custom headers or modify request
  requestParams.headers = requestParams.headers || {};
  requestParams.headers['X-Request-ID'] = randomUUID();
  requestParams.headers['X-Test-Start-Time'] = Date.now().toString();
  
  return next();
}

/**
 * After response hook - can be used to capture metrics or validate responses
 * @param {Object} requestParams - The request parameters
 * @param {Object} response - The response object
 * @param {Object} context - Artillery context
 * @param {Object} ee - Event emitter
 * @param {Function} next - Callback to continue
 */
function afterResponse(requestParams, response, context, ee, next) {
  // Calculate request duration
  const startTime = parseInt(requestParams.headers['X-Test-Start-Time'] || 0);
  const duration = startTime ? Date.now() - startTime : null;
  
  // Emit custom metrics
  if (duration) {
    ee.emit('customStat', { 
      stat: 'custom.request.duration', 
      value: duration 
    });
  }
  
  // Emit custom metrics based on status code
  if (response.statusCode >= 500) {
    ee.emit('customStat', { 
      stat: 'custom.errors.5xx', 
      value: 1 
    });
  } else if (response.statusCode >= 400) {
    ee.emit('customStat', { 
      stat: 'custom.errors.4xx', 
      value: 1 
    });
  } else if (response.statusCode >= 200 && response.statusCode < 300) {
    ee.emit('customStat', { 
      stat: 'custom.success.2xx', 
      value: 1 
    });
  }
  
  return next();
}

/**
 * Set initial context variables for each virtual user
 * @param {Object} context - Artillery context
 * @param {Object} events - Event emitter
 * @param {Function} done - Callback
 */
function setInitialContext(context, events, done) {
  // Set custom variables for this virtual user
  context.vars.userId = randomUUID();
  context.vars.sessionId = randomUUID();
  context.vars.startTime = Date.now();
  context.vars.userType = ['premium', 'standard', 'free'][randomNumber(0, 2)];
  
  return done();
}

/**
 * Custom function for test scenarios
 * Simulates realistic user behavior patterns
 */
function simulateUserBehavior(context, events, done) {
  // Add realistic delays based on user type
  const thinkTime = context.vars.userType === 'premium' ? 1000 : 3000;
  
  setTimeout(() => {
    return done();
  }, thinkTime);
}

/**
 * Log test phase transitions
 */
function logPhaseChange(phase, context, events, done) {
  console.log(`Test phase: ${phase}`);
  events.emit('customStat', {
    stat: `custom.phase.${phase}`,
    value: 1
  });
  return done();
}

// Export functions for Artillery to use
module.exports = {
  // Utility functions (can be used in templates)
  randomString,
  randomNumber,
  timestamp,
  unixTimestamp,
  randomEmail,
  randomUUID,
  
  // Hook functions
  beforeRequest,
  afterResponse,
  setInitialContext,
  simulateUserBehavior,
  logPhaseChange
};
