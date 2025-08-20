export const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:8001";

export function makeAuthHeader(token: string): Record<string, string> {
  return { Authorization: `Bearer ${token}` };
}

async function withTimeout<T>(p: Promise<T>, ms = 15000): Promise<T> {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms);
  try {
    // @ts-expect-error abort controller unused
    const res = await p;
    return res as T;
  } finally {
    clearTimeout(t);
  }
}

export async function login(username: string, password: string): Promise<string> {
  const res = await withTimeout(fetch(`${API_BASE}/auth/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password })
  }));
  if (!(res as Response).ok) {
    const msg = await (res as Response).text();
    throw new Error(`Echec login (${(res as Response).status}): ${msg}`);
  }
  const data = await (res as Response).json();
  return data.access_token as string;
}

export async function me(token: string): Promise<{ username: string; role: string }> {
  const res = await withTimeout(fetch(`${API_BASE}/auth/me`, {
    headers: makeAuthHeader(token)
  }));
  if (!(res as Response).ok) throw new Error(`Echec /auth/me ${(res as Response).status}`);
  return (await (res as Response).json()) as { username: string; role: string };
}

export async function getSecret(token: string): Promise<string> {
  const res = await withTimeout(fetch(`${API_BASE}/debug/secret`, {
    headers: makeAuthHeader(token)
  }));
  if (!(res as Response).ok) throw new Error(`Echec /debug/secret ${(res as Response).status}`);
  const data = await (res as Response).json();
  return data.secret as string;
}

/** Admin Users */
export type UsersOrder = "created_asc" | "created_desc" | "username_asc" | "username_desc";
export interface UsersMeta { total: number; pages: number; page: number; page_size: number; etag: string }
export interface UserOut { id: number; username: string; role: string }
export interface UsersListOut { meta: UsersMeta; data: UserOut[] }

export function usersCacheKey(page: number, pageSize: number, order: UsersOrder) {
  return `users:${page}:${pageSize}:${order}`;
}
export function saveUsersCache(key: string, payload: UsersListOut) {
  localStorage.setItem(key, JSON.stringify(payload));
}
export function getUsersCache(key: string): UsersListOut | null {
  const raw = localStorage.getItem(key);
  if (!raw) return null;
  try { return JSON.parse(raw) as UsersListOut } catch { return null }
}

export async function fetchUsers(
  token: string,
  page: number,
  pageSize: number,
  order: UsersOrder,
  prevEtag?: string
): Promise<{ payload: UsersListOut | null; etag?: string; notModified: boolean }> {
  const url = `${API_BASE}/users?page=${page}&page_size=${pageSize}&order=${order}`;
  const headers: Record<string, string> = { ...makeAuthHeader(token) };
  if (prevEtag) headers["If-None-Match"] = prevEtag;
  const res = await withTimeout(fetch(url, { headers }));
  // 304: pas de body
  if ((res as Response).status === 304) {
    return { payload: null, etag: prevEtag, notModified: true };
  }
  if (!(res as Response).ok) {
    const msg = await (res as Response).text();
    throw new Error(`Echec /users (${(res as Response).status}): ${msg}`);
  }
  const payload = await (res as Response).json() as UsersListOut;
  const etag = (res as Response).headers.get("ETag") ?? payload?.meta?.etag;
  return { payload, etag: etag ?? undefined, notModified: false };
}
