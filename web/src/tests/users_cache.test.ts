import { describe, it, expect, beforeEach, vi } from "vitest";
import { usersCacheKey, saveUsersCache, getUsersCache } from "../api";

const store: Record<string, string> = {};
vi.stubGlobal("localStorage", {
  getItem: (k: string) => (k in store ? store[k] : null),
  setItem: (k: string, v: string) => { store[k] = v; },
  removeItem: (k: string) => { delete store[k]; },
  clear: () => { for (const k in store) delete store[k]; },
  key: (i: number) => Object.keys(store)[i] ?? null,
  get length() { return Object.keys(store).length; }
} as any);

beforeEach(() => {
  for (const k in store) delete store[k];
});

describe("users cache helpers", () => {
  it("usersCacheKey OK", () => {
    expect(usersCacheKey(1, 50, "created_desc")).toBe("users:1:50:created_desc");
  });
  it("save/get roundtrip", () => {
    const key = usersCacheKey(2, 10, "username_asc");
    const payload = { meta: { total: 1, pages: 1, page: 1, page_size: 10, etag: "abc" }, data: [{ id: 1, username: "u", role: "user" }] };
    saveUsersCache(key, payload as any);
    const got = getUsersCache(key);
    expect(got?.meta?.etag).toBe("abc");
    expect(got?.data?.[0]?.username).toBe("u");
  });
});
