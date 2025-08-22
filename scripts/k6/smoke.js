import http from 'k6/http'; import { check, sleep } from 'k6';
export const options = { vus: 1, duration: '10s', thresholds: { http_req_failed: ['rate<0.05'], http_req_duration: ['p(95)<800'] } };
const BASE = __ENV.BASE_URL || 'http://127.0.0.1:8000';
export default function () { const r = http.get(`${BASE}/healthz`); check(r, { '200': x => x.status === 200 }); sleep(1); }
