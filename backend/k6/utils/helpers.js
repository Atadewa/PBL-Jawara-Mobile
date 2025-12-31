import { check, sleep } from "k6";
import { Rate, Trend, Counter } from "k6/metrics";

// Custom metrics
export const errorRate = new Rate("errors");
export const successRate = new Rate("success");
export const apiDuration = new Trend("api_duration");
export const authFailures = new Counter("auth_failures");

// Helper function untuk membuat headers dengan auth
export function getAuthHeaders(token) {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  };
}

// Helper function untuk check response
export function checkResponse(response, expectedStatus = 200, tag = "request") {
  const checks = {
    [`${tag}: status is ${expectedStatus}`]: (r) => r.status === expectedStatus,
    [`${tag}: response time < 1000ms`]: (r) => r.timings.duration < 1000,
  };

  const result = check(response, checks);

  // Track metrics
  errorRate.add(!result);
  successRate.add(result);
  apiDuration.add(response.timings.duration);

  // Track auth failures
  if (response.status === 401 || response.status === 403) {
    authFailures.add(1);
  }

  return result;
}

// Helper function untuk check response dengan body validation
export function checkResponseWithBody(
  response,
  expectedStatus = 200,
  tag = "request",
  bodyChecks = {}
) {
  const statusChecks = {
    [`${tag}: status is ${expectedStatus}`]: (r) => r.status === expectedStatus,
    [`${tag}: response time < 1000ms`]: (r) => r.timings.duration < 1000,
    [`${tag}: has body`]: (r) => r.body && r.body.length > 0,
  };

  // Merge with custom body checks
  const allChecks = { ...statusChecks, ...bodyChecks };

  const result = check(response, allChecks);

  errorRate.add(!result);
  successRate.add(result);
  apiDuration.add(response.timings.duration);

  if (response.status === 401 || response.status === 403) {
    authFailures.add(1);
  }

  return result;
}

// Helper untuk random sleep (mensimulasikan user think time)
export function randomSleep(min = 1, max = 3) {
  const sleepTime = Math.random() * (max - min) + min;
  sleep(sleepTime);
}

// Helper untuk generate random data
export function randomString(length = 10) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

export function randomNumber(min = 1000, max = 100000) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function randomDate(daysBack = 30) {
  const date = new Date();
  date.setDate(date.getDate() - Math.floor(Math.random() * daysBack));
  return date.toISOString().split("T")[0]; // YYYY-MM-DD
}

// Helper untuk log errors
export function logError(response, context = "") {
  if (response.status >= 400) {
    console.error(
      `[ERROR] ${context} - Status: ${response.status}, Body: ${response.body}`
    );
  }
}

// Sample data generators untuk berbagai endpoints
export const sampleData = {
  income: () => ({
    source_name: `Income Source ${randomString(5)}`,
    description: `Test income description ${randomString(10)}`,
    amount: randomNumber(10000, 500000),
    date: randomDate(30),
    payment_method: ["cash", "transfer", "check"][
      Math.floor(Math.random() * 3)
    ],
    // Required fields untuk admin
    rw: Math.floor(Math.random() * 5) + 1, // RW 1-5
    rt: Math.floor(Math.random() * 10) + 1, // RT 1-10
  }),

  expense: () => ({
    category: ["utilities", "maintenance", "supplies"][
      Math.floor(Math.random() * 3)
    ],
    description: `Test expense ${randomString(8)}`,
    amount: randomNumber(5000, 200000),
    date: randomDate(30),
    payment_method: ["cash", "transfer"][Math.floor(Math.random() * 2)],
    // Required fields untuk admin
    rw: Math.floor(Math.random() * 5) + 1, // RW 1-5
    rt: Math.floor(Math.random() * 10) + 1, // RT 1-10
  }),

  aspiration: () => ({
    title: `Aspirasi ${randomString(8)}`,
    description: `Deskripsi aspirasi untuk testing load ${randomString(20)}`,
    category: ["infrastructure", "security", "cleanliness", "other"][
      Math.floor(Math.random() * 4)
    ],
    priority: ["low", "medium", "high"][Math.floor(Math.random() * 3)],
    // Required field - resident_id harus valid
    resident_id: Math.floor(Math.random() * 100) + 1, // Random resident ID 1-100
  }),

  event: () => ({
    title: `Event ${randomString(6)}`,
    description: `Event description ${randomString(15)}`,
    date: randomDate(60),
    location: `Location ${randomString(5)}`,
    max_participants: randomNumber(10, 100),
  }),
};

export default {
  getAuthHeaders,
  checkResponse,
  checkResponseWithBody,
  randomSleep,
  randomString,
  randomNumber,
  randomDate,
  logError,
  sampleData,
};
