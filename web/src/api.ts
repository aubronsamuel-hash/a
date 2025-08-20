export const API_BASE =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8001";

export function makeAuthHeader(token: string): Record<string, string> {
  return { Authorization: `Bearer ${token}` };
}

async function withTimeout<T>(p: Promise<T>, ms = 15000): Promise<T> {
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error("timeout")), ms)
  );
  return (await Promise.race([p, timeout])) as T;
}

export async function login(
  username: string,
  password: string
): Promise<string> {
  const res = await withTimeout(
    fetch(`${API_BASE}/auth/token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password })
    })
  );
  if (!res.ok) {
    const msg = await res.text();
    throw new Error(`Echec login (${res.status}): ${msg}`);
  }
  const data = await res.json();
  return data.access_token as string;
}

export async function me(token: string): Promise<{ username: string }> {
  const res = await withTimeout(
    fetch(`${API_BASE}/auth/me`, {
      headers: makeAuthHeader(token)
    })
  );
  if (!res.ok) {
    throw new Error(`Echec /auth/me ${res.status}`);
  }
  return (await res.json()) as { username: string };
}

export async function getSecret(token: string): Promise<string> {
  const res = await withTimeout(
    fetch(`${API_BASE}/debug/secret`, {
      headers: makeAuthHeader(token)
    })
  );
  if (!res.ok) {
    throw new Error(`Echec /debug/secret ${res.status}`);
  }
  const data = await res.json();
  return data.secret as string;
}
