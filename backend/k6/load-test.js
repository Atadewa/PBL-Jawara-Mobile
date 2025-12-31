/**
 * k6 Load Test
 *
 * Purpose: Test system performance under expected normal load
 * Scenario: Simulate realistic user behavior with read-heavy operations
 * VUs: Ramp up from 0 to 50 users
 * Duration: 5 minutes
 *
 * Run: k6 run k6/load-test.js
 */

import http from "k6/http";
import { sleep, group } from "k6";
import { config, thresholds } from "./config.js";
import {
  getAuthHeaders,
  checkResponse,
  checkResponseWithBody,
  randomSleep,
  sampleData,
  logError,
} from "./utils/helpers.js";

export const options = {
  stages: [
    { duration: "1m", target: 10 }, // Ramp up to 10 users
    { duration: "2m", target: 30 }, // Ramp up to 30 users
    { duration: "1m", target: 50 }, // Ramp up to 50 users (peak)
    { duration: "1m", target: 0 }, // Ramp down to 0
  ],
  thresholds: thresholds.load,
  tags: {
    test_type: "load",
  },
};

export default function () {
  const BASE_URL = config.BASE_URL;
  const headers = getAuthHeaders(config.AUTH_TOKEN);

  // Realistic user behavior: mostly reading data (80%), occasionally writing (20%)
  const randomAction = Math.random();

  if (randomAction < 0.8) {
    // 80% - Read operations
    readOperations(BASE_URL, headers);
  } else {
    // 20% - Write operations
    writeOperations(BASE_URL, headers);
  }
}

function readOperations(BASE_URL, headers) {
  group("Read Operations", () => {
    // Random user flows:
    const flow = Math.random();

    if (flow < 0.3) {
      // Flow 1: Check finances (30%)
      group("Financial Overview", () => {
        // Get summary
        const summaryRes = http.get(`${BASE_URL}/summary`, { headers });
        checkResponse(summaryRes, 200, "summary");
        randomSleep(1, 2);

        // Get incomes
        const incomesRes = http.get(`${BASE_URL}/incomes`, { headers });
        checkResponse(incomesRes, 200, "incomes list");
        randomSleep(1, 2);

        // Get expenses
        const expensesRes = http.get(`${BASE_URL}/expenses`, { headers });
        checkResponse(expensesRes, 200, "expenses list");
        randomSleep(2, 3);
      });
    } else if (flow < 0.6) {
      // Flow 2: Check aspirations (30%)
      group("Aspirations Check", () => {
        // Get all aspirations
        const aspirationsRes = http.get(`${BASE_URL}/aspirations`, { headers });
        checkResponse(aspirationsRes, 200, "aspirations list");

        // Parse and get first aspiration detail if exists
        try {
          const body = JSON.parse(aspirationsRes.body);
          if (body.data && body.data.length > 0) {
            const firstId = body.data[0].id;
            randomSleep(1, 2);

            const detailRes = http.get(`${BASE_URL}/aspirations/${firstId}`, {
              headers,
            });
            checkResponse(detailRes, 200, "aspiration detail");
          }
        } catch (e) {
          // Ignore parse errors
        }

        randomSleep(2, 4);
      });
    } else if (flow < 0.85) {
      // Flow 3: Check events (25%)
      group("Events Check", () => {
        const eventsRes = http.get(`${BASE_URL}/events`, { headers });
        checkResponse(eventsRes, 200, "events list");
        randomSleep(2, 4);
      });
    } else {
      // Flow 4: Check profile and broadcasts (15%)
      group("Profile & Broadcasts", () => {
        // Get user profile
        const authRes = http.get(`${BASE_URL}/auth/me`, { headers });
        checkResponse(authRes, 200, "user profile");
        randomSleep(1, 2);

        // Get broadcasts
        const broadcastsRes = http.get(`${BASE_URL}/broadcasts`, { headers });
        checkResponse(broadcastsRes, 200, "broadcasts list");
        randomSleep(2, 3);
      });
    }
  });
}

function writeOperations(BASE_URL, headers) {
  group("Write Operations", () => {
    const writeType = Math.random();

    if (writeType < 0.4) {
      // 40% - Create income
      group("Create Income", () => {
        const payload = JSON.stringify(sampleData.income());
        const res = http.post(`${BASE_URL}/incomes`, payload, { headers });

        // Check if successful (201) or forbidden (403)
        const success =
          checkResponse(res, 201, "create income") ||
          checkResponse(res, 403, "create income (forbidden)");

        if (!success) {
          logError(res, "Create Income");
        }

        randomSleep(2, 4);
      });
    } else if (writeType < 0.7) {
      // 30% - Create expense
      group("Create Expense", () => {
        const payload = JSON.stringify(sampleData.expense());
        const res = http.post(`${BASE_URL}/expenses`, payload, { headers });

        const success =
          checkResponse(res, 201, "create expense") ||
          checkResponse(res, 403, "create expense (forbidden)");

        if (!success) {
          logError(res, "Create Expense");
        }

        randomSleep(2, 4);
      });
    } else {
      // 30% - Create aspiration (menggunakan token user 2 untuk menghindari 403)
      group("Create Aspiration", () => {
        // Gunakan AUTH_TOKEN_2 jika tersedia, fallback ke AUTH_TOKEN
        const aspirationToken = __ENV.AUTH_TOKEN_2 || __ENV.AUTH_TOKEN;
        const aspirationHeaders = {
          "Content-Type": "application/json",
          Authorization: `Bearer ${aspirationToken}`,
        };

        const payload = JSON.stringify(sampleData.aspiration());
        const res = http.post(`${BASE_URL}/aspirations`, payload, {
          headers: aspirationHeaders,
        });

        const success = checkResponse(res, 201, "create aspiration");

        if (!success) {
          logError(res, "Create Aspiration");
        }

        randomSleep(2, 4);
      });
    }
  });
}

export function handleSummary(data) {
  return {
    stdout: textSummary(data),
    "k6/results/load-test-summary.json": JSON.stringify(data),
    "k6/results/load-test-summary.html": htmlReport(data),
  };
}

function textSummary(data) {
  const metrics = data.metrics;

  let summary = "\n";
  summary += "  ✓ Load Test Complete\n";
  summary += "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";

  if (metrics.http_reqs) {
    summary += `  Total Requests: ${metrics.http_reqs.values.count}\n`;
    const duration = data.state.testRunDurationMs / 1000;
    const rps = (metrics.http_reqs.values.count / duration).toFixed(2);
    summary += `  Requests/sec: ${rps}\n`;
  }

  if (metrics.http_req_duration) {
    summary += `  Avg Response Time: ${metrics.http_req_duration.values.avg.toFixed(
      2
    )}ms\n`;
    summary += `  Med Response Time: ${metrics.http_req_duration.values.med.toFixed(
      2
    )}ms\n`;
    summary += `  95th Percentile: ${metrics.http_req_duration.values[
      "p(95)"
    ].toFixed(2)}ms\n`;
    summary += `  99th Percentile: ${metrics.http_req_duration.values[
      "p(99)"
    ].toFixed(2)}ms\n`;
  }

  if (metrics.http_req_failed) {
    const failRate = (metrics.http_req_failed.values.rate * 100).toFixed(2);
    const failCount = metrics.http_req_failed.values.passes || 0;
    summary += `  Failed Requests: ${failCount} (${failRate}%)\n`;
  }

  if (
    metrics.errors &&
    metrics.errors.values &&
    metrics.errors.values.rate !== undefined
  ) {
    summary += `  Error Rate: ${(metrics.errors.values.rate * 100).toFixed(
      2
    )}%\n`;
  }

  if (
    metrics.success &&
    metrics.success.values &&
    metrics.success.values.rate !== undefined
  ) {
    summary += `  Success Rate: ${(metrics.success.values.rate * 100).toFixed(
      2
    )}%\n`;
  }

  if (metrics.auth_failures && metrics.auth_failures.values) {
    summary += `  Auth Failures: ${metrics.auth_failures.values.count || 0}\n`;
  }

  summary += "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";

  return summary;
}

function htmlReport(data) {
  // Simple HTML report template
  return `<!DOCTYPE html>
<html>
<head>
  <title>k6 Load Test Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    .metric { font-weight: bold; }
  </style>
</head>
<body>
  <h1>k6 Load Test Report</h1>
  <p>Generated: ${new Date().toISOString()}</p>
  <table>
    <tr><th>Metric</th><th>Value</th></tr>
    <tr><td class="metric">Total Requests</td><td>${
      data.metrics.http_reqs?.values.count || 0
    }</td></tr>
    <tr><td class="metric">Avg Response Time</td><td>${
      data.metrics.http_req_duration?.values.avg.toFixed(2) || 0
    }ms</td></tr>
    <tr><td class="metric">95th Percentile</td><td>${
      data.metrics.http_req_duration?.values["p(95)"].toFixed(2) || 0
    }ms</td></tr>
    <tr><td class="metric">Failed Requests</td><td>${
      (data.metrics.http_req_failed?.values.rate * 100).toFixed(2) || 0
    }%</td></tr>
  </table>
</body>
</html>`;
}
