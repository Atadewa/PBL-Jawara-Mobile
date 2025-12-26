# Testing Commands - Jawara API Backend

Panduan lengkap perintah untuk menjalankan tests dari yang paling general hingga spesifik.

## 📋 Table of Contents

- [Basic Commands](#basic-commands)
- [Run Specific Tests](#run-specific-tests)
- [Advanced Options](#advanced-options)
- [Examples](#examples)

---

## 🚀 Basic Commands

### General Testing

```bash
# Run all tests
npm test

# Run all tests with verbose output
npm test -- --verbose

# Run tests in watch mode (auto-rerun on file changes)
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### By Test Type

```bash
# Unit tests only
npm run test:unit

# Integration tests only
npm run test:integration
```

---

## 🎯 Run Specific Tests

### By File Path

```bash
# Specific test file
npm test -- tests/unit/middlewares/requireAuth.test.js

# Multiple files
npm test -- tests/unit/routes/auth.routes.test.js tests/unit/routes/income.routes.test.js

# All tests in a folder
npm test -- tests/unit/middlewares
npm test -- tests/unit/routes
npm test -- tests/integration
```

### By Test Name Pattern

```bash
# Tests containing "admin"
npm test -- --testNamePattern="admin"

# Tests containing "should return 401"
npm test -- --testNamePattern="401"

# Tests in specific describe block
npm test -- --testNamePattern="Token Validation"

# Tests with regex pattern
npm test -- --testNamePattern="(admin|user|role)"
```

### By File Pattern

```bash
# All files ending with .test.js in routes folder
npm test -- --testPathPattern=routes

# All middleware tests
npm test -- --testPathPattern=middlewares

# Exclude integration tests
npm test -- --testPathIgnorePatterns=integration
```

---

## ⚙️ Advanced Options

### Combine Multiple Options

```bash
# Specific file with verbose output
npm test -- tests/unit/routes/income.routes.test.js --verbose

# Specific file in watch mode
npm test -- tests/unit/middlewares/requireAuth.test.js --watch

# Folder with coverage
npm test -- tests/unit/routes --coverage

# Pattern match with watch
npm test -- --testNamePattern="GET /incomes" --watch
```

### Debugging Tests

```bash
# Show detailed error messages
npm test -- --verbose

# Run only failed tests from previous run
npm test -- --onlyFailures

# Run tests in specific order
npm test -- --runInBand

# Show full diff on failures
npm test -- --verbose --expand
```

### Coverage Options

```bash
# Coverage for specific folder
npm test -- tests/unit/middlewares --coverage

# Coverage with HTML report (opens in browser)
npm run test:coverage
# Then open: coverage/lcov-report/index.html

# Coverage with minimum threshold
npm test -- --coverage --coverageThreshold='{"global":{"branches":80}}'
```

### Performance

```bash
# Limit number of workers
npm test -- --maxWorkers=2

# Run in band (sequential, better for debugging)
npm test -- --runInBand

# Set timeout for slow tests
npm test -- --testTimeout=10000
```

---

## 💡 Examples

### Development Workflow

```bash
# 1. Watch mode saat development
npm run test:watch

# 2. Test file yang sedang dikerjakan
npm test -- tests/unit/routes/income.routes.test.js --watch

# 3. Test dengan nama tertentu
npm test -- --testNamePattern="should create new income" --watch
```

### Before Commit

```bash
# 1. Run all unit tests
npm run test:unit

# 2. Check coverage
npm run test:coverage

# 3. Run all tests
npm test
```

### Debugging Failed Tests

```bash
# 1. Run specific failed test dengan verbose
npm test -- tests/unit/routes/income.routes.test.js --verbose

# 2. Run hanya test yang gagal
npm test -- --onlyFailures

# 3. Run sequential untuk debugging
npm test -- --runInBand --verbose
```

### Integration Testing

```bash
# 1. Run semua integration tests
npm run test:integration

# 2. Run specific integration test
npm test -- tests/integration/api.integration.test.js

# 3. Skip integration tests
npm test -- --testPathIgnorePatterns=integration
```

---

## 📁 Test File Structure Reference

```
tests/
├── unit/
│   ├── middlewares/
│   │   └── requireAuth.test.js          # Auth middleware tests
│   └── routes/
│       ├── auth.routes.test.js          # Auth routes tests
│       └── income.routes.test.js        # Income routes tests
└── integration/
    └── api.integration.test.js          # E2E API tests
```

---

## 🔍 Quick Reference

| Command                                   | Description                |
| ----------------------------------------- | -------------------------- |
| `npm test`                                | Run all tests              |
| `npm run test:unit`                       | Unit tests only            |
| `npm run test:integration`                | Integration tests only     |
| `npm run test:watch`                      | Watch mode                 |
| `npm run test:coverage`                   | Coverage report            |
| `npm test -- <file>`                      | Specific file              |
| `npm test -- --testNamePattern="<name>"`  | By test name               |
| `npm test -- --testPathPattern=<pattern>` | By file pattern            |
| `npm test -- --verbose`                   | Detailed output            |
| `npm test -- --watch`                     | Watch specific test        |
| `npm test -- --coverage`                  | Coverage for specific test |

---

## 💻 Package.json Scripts

```json
{
  "scripts": {
    "test": "jest --verbose",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration"
  }
}
```

---

## 🎯 Tips & Best Practices

1. **Development**: Gunakan `--watch` untuk auto-rerun saat save
2. **Debugging**: Tambahkan `--verbose` untuk detail error
3. **Performance**: Gunakan `--testPathPattern` untuk fokus ke area tertentu
4. **Coverage**: Check coverage sebelum commit
5. **CI/CD**: Selalu run semua tests dengan `npm test`

---

## 📚 Related Documentation

- [TESTING.md](TESTING.md) - Comprehensive testing guide
- [README.testing.md](README.testing.md) - Testing setup summary
- [Jest Documentation](https://jestjs.io/docs/cli) - Official Jest CLI docs

---

**Last Updated**: December 26, 2025
