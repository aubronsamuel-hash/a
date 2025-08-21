import http from "k6/http";
import { check, sleep } from "k6";

const BASE = __ENV.BASE || "http://backend:8001";

export const options = {
  scenarios: {
    smoke: { executor: "constant-vus", vus: 10, duration: "20s" },
  },
  thresholds: {
    http_req_failed: ["rate<0.01"],          // < 1% d erreurs
    http_req_duration: ["p(95)<500"],        // p95 < 500ms
  },
  summaryTrendStats: ["avg","min","med","p(90)","p(95)","p(99)","max"],
};

export default function () {
  // 1) /healthz
  const r1 = http.get(`${BASE}/healthz`, { tags: { name: "GET /healthz" } });
  check(r1, { "healthz 200": (r) => r.status === 200 });

  // 2) /metrics
  const r2 = http.get(`${BASE}/metrics`, { tags: { name: "GET /metrics" } });
  check(r2, { "metrics 200": (r) => r.status === 200 && String(r.body || "").includes("http_requests_total") });

  // 3) /echo
  const payload = JSON.stringify({ message: "hi" });
  const headers = { "Content-Type": "application/json" };
  const r3 = http.post(`${BASE}/echo?page=1&page_size=5`, payload, { headers, tags: { name: "POST /echo" } });
  check(r3, {
    "echo 200": (r) => r.status === 200,
    "echo page passthrough": (r) => (r.json("page") === 1 && r.json("page_size") === 5),
  });

  sleep(0.2);
}
