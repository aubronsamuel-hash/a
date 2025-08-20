import React, { useEffect, useState } from "react";
import { login, me, getSecret } from "./api";
import Login from "./components/Login";
import AdminUsers from "./components/AdminUsers";

export default function App() {
  const [token, setToken] = useState<string | null>(localStorage.getItem("token"));
  const [username, setUsername] = useState<string>("");
  const [role, setRole] = useState<string>("");

  useEffect(() => {
    if (!token) return;
    me(token).then((u) => { setUsername(u.username); setRole(u.role); }).catch(() => { setUsername(""); setRole(""); });
  }, [token]);

  const handleLogin = async (u: string, p: string) => {
    const t = await login(u, p);
    localStorage.setItem("token", t);
    setToken(t);
    const info = await me(t);
    setUsername(info.username);
    setRole(info.role);
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    setToken(null);
    setUsername("");
    setRole("");
  };

  const [secret, setSecret] = useState<string>("");

  const fetchSecret = async () => {
    if (!token) return;
    const s = await getSecret(token);
    setSecret(s);
  };

  if (!token) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-full max-w-sm bg-white shadow rounded-2xl p-6">
          <h1 className="text-2xl font-bold mb-4">Connexion</h1>
          <Login onLogin={handleLogin} />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-4xl mx-auto space-y-4">
        <div className="bg-white shadow rounded-2xl p-6 flex items-center justify-between">
          <div>
            <div className="text-sm text-gray-500">Connecte en tant que</div>
            <div className="text-xl font-semibold">{username} {role ? <span className="text-xs text-gray-500">({role})</span> : null}</div>
          </div>
          <button onClick={handleLogout} className="px-3 py-2 rounded-xl border hover:bg-gray-50">
            Deconnexion
          </button>
        </div>

        <div className="bg-white shadow rounded-2xl p-6">
          <div className="flex items-center gap-3">
            <button onClick={fetchSecret} className="px-3 py-2 rounded-xl border hover:bg-gray-50">
              Charger secret
            </button>
            {secret && <span className="text-green-700">{secret}</span>}
          </div>
        </div>

        {role === "admin" && (
          <div>
            <h2 className="text-lg font-semibold mb-2">Admin Users</h2>
            <AdminUsers token={token} />
          </div>
        )}
      </div>
    </div>
  );
}
