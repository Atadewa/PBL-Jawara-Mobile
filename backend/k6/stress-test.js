/**
 * k6 Stress Test
 *
 * Purpose: Test system behavior beyond normal load to find breaking point
 * VUs: Ramp up to 100+ users
 * Duration: 7 minutes
 *
 * Run: k6 run k6/stress-test.js
 */

import http from "k6/http";
import { sleep, group } from "k6";
import { config, thresholds } from "./config.js";
import {
  getAuthHeaders,
  checkResponse,
  randomSleep,
  sampleData,
} from "./utils/helpers.js";

export const options = {
  stages: [
    { duration: "1m", target: 20 }, // Ramp up to 20 users
    { duration: "2m", target: 50 }, // Ramp up to 50 users
    { duration: "2m", target: 100 }, // Ramp up to 100 users (stress level)
    { duration: "1m", target: 150 }, // Push to 150 users (breaking point)
    { duration: "1m", target: 0 }, // Ramp down
  ],
  thresholds: thresholds.stress,
  tags: {
    test_type: "stress",
  },
};

export default function () {
  const BASE_URL = config.BASE_URL;
  const headers = getAuthHeaders(config.AUTH_TOKEN);

  // Aggressive read pattern
  group("Stress - Read Heavy", () => {
    // Parallel requests simulation
    const responses = http.batch([
      ["GET", `${BASE_URL}/health`, null, { headers }],
      ["GET", `${BASE_URL}/auth/me`, null, { headers }],
      ["GET", `${BASE_URL}/incomes`, null, { headers }],
      ["GET", `${BASE_URL}/expenses`, null, { headers }],
      ["GET", `${BASE_URL}/aspirations`, null, { headers }],
    ]);

    responses.forEach((res, index) => {
      checkResponse(res, 200, `stress-batch-${index}`);
    });

    sleep(0.5); // Short sleep to maintain pressure
  });

  // Occasional writes
  if (Math.random() < 0.3) {
    group("Stress - Write Operation", () => {
      const payload = JSON.stringify(sampleData.income());
      const res = http.post(`${BASE_URL}/incomes`, payload, { headers });
      checkResponse(res, 201, "stress-write") ||
        checkResponse(res, 403, "stress-write-forbidden");
      sleep(0.5);
    });
  }

  randomSleep(0.5, 1.5);
}

export function handleSummary(data) {
  return {
    stdout: textSummary(data),
    "k6/results/stress-test-summary.json": JSON.stringify(data),
  };
}

function textSummary(data) {
  const metrics = data.metrics;

  let summary = "\n";
  summary += "  ⚡ Stress Test Complete\n";
  summary += "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";

  if (metrics.http_reqs) {
    summary += `  Total Requests: ${metrics.http_reqs.values.count}\n`;
  }

  if (metrics.http_req_duration) {
    summary += `  Avg Response Time: ${metrics.http_req_duration.values.avg.toFixed(
      2
    )}ms\n`;
    summary += `  Max Response Time: ${metrics.http_req_duration.values.max.toFixed(
      2
    )}ms\n`;
    summary += `  95th Percentile: ${metrics.http_req_duration.values[
      "p(95)"
    ].toFixed(2)}ms\n`;
  }

  if (metrics.http_req_failed) {
    const failRate = (metrics.http_req_failed.values.rate * 100).toFixed(2);
    summary += `  Failed Requests: ${failRate}%\n`;
  }

  summary += "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
  summary += "  💡 Check when response times degraded or errors increased\n";

  return summary;
}
