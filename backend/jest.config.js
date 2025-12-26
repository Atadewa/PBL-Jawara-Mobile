module.exports = {
  testEnvironment: "node",
  coverageDirectory: "coverage",
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/server.js", // exclude server entry point
    "!src/**/*.test.js",
    "!src/**/*.spec.js",
  ],
  testMatch: ["**/__tests__/**/*.js", "**/?(*.)+(spec|test).js"],
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50,
    },
  },
  setupFilesAfterEnv: ["<rootDir>/tests/setup.js"],
  testTimeout: 10000,
  verbose: true,
  roots: ["<rootDir>/tests", "<rootDir>/src"],
  // Load .env.test file before running tests
  setupFiles: ["<rootDir>/tests/loadEnv.js"],
};
