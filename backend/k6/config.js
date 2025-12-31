// k6 Load Testing Configuration
export const config = {
  // Base URL - ganti sesuai environment
  // Local: http://localhost:3000
  // Production: https://your-api.vercel.app
  BASE_URL: __ENV.BASE_URL || 'http://localhost:3000',
  
  // Auth token - dapatkan dari script get-test-token.js
  AUTH_TOKEN: __ENV.AUTH_TOKEN || '',
  
  // Test user credentials (untuk generate token jika diperlukan)
  TEST_USER_EMAIL: __ENV.TEST_USER_EMAIL || '',
  TEST_USER_PASSWORD: __ENV.TEST_USER_PASSWORD || '',
};

// Thresholds untuk berbagai metrics
export const thresholds = {
  smoke: {
    http_req_duration: ['p(95)<500'], // 95% requests harus < 500ms
    http_req_failed: ['rate<0.01'],   // error rate < 1%
  },
  load: {
    http_req_duration: ['p(95)<800', 'p(99)<1200'],
    http_req_failed: ['rate<0.05'],   // error rate < 5%
    http_reqs: ['rate>10'],           // minimal 10 req/s
  },
  stress: {
    http_req_duration: ['p(95)<1500'],
    http_req_failed: ['rate<0.10'],   // error rate < 10%
  },
  spike: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.15'],   // error rate < 15%
  },
};

export default config;
