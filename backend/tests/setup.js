// Setup file untuk Jest
// File ini akan dijalankan sebelum semua test

// Suppress console logs selama testing (opsional)
// global.console = {
//   ...console,
//   log: jest.fn(),
//   debug: jest.fn(),
//   info: jest.fn(),
// };

// Set timeout default untuk semua test
jest.setTimeout(10000);

// Cleanup setelah semua test selesai
afterAll(() => {
  // Cleanup jika diperlukan
});
