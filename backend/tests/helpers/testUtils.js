// Test Helpers and Utilities

/**
 * Create mock request object
 */
const createMockRequest = (overrides = {}) => {
  return {
    body: {},
    params: {},
    query: {},
    headers: {},
    userContext: null,
    ...overrides,
  };
};

/**
 * Create mock response object
 */
const createMockResponse = () => {
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    sendStatus: jest.fn().mockReturnThis(),
    set: jest.fn().mockReturnThis(),
  };
  return res;
};

/**
 * Create mock next function
 */
const createMockNext = () => jest.fn();

/**
 * Create mock user context untuk testing
 */
const createMockUserContext = (overrides = {}) => {
  return {
    appUser: {
      id: "test-user-id",
      email: "test@example.com",
      phone: "081234567890",
      name: "Test User",
      ...overrides.appUser,
    },
    roleNames: overrides.roleNames || ["admin"],
    scope: overrides.scope || {
      mode: "all",
      rw: null,
      rt: null,
    },
  };
};

/**
 * Wait for a specific amount of time
 */
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Assert that a function throws a specific error
 */
const expectAsyncError = async (fn, expectedError) => {
  try {
    await fn();
    throw new Error("Expected function to throw an error");
  } catch (error) {
    expect(error.message).toContain(expectedError);
  }
};

module.exports = {
  createMockRequest,
  createMockResponse,
  createMockNext,
  createMockUserContext,
  wait,
  expectAsyncError,
};
