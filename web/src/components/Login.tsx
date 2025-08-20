import React, { useState } from "react";

export default function Login({ onLogin }: { onLogin: (u: string, p: string) => Promise<void> }) {
  const [u, setU] = useState("");
  const [p, setP] = useState("");
  const [err, setErr] = useState<string>("");

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr("");
    try {
      await onLogin(u, p);
    } catch (e: any) {
      setErr(e?.message ?? "Erreur inconnue");
    }
  };

  return (
    <form onSubmit={submit} className="space-y-4">
      <div>
        <label className="block text-sm mb-1">Nom d utilisateur</label>
        <input
          value={u}
          onChange={(e) => setU(e.target.value)}
          className="w-full border rounded-xl px-3 py-2"
        />
      </div>
      <div>
        <label className="block text-sm mb-1">Mot de passe</label>
        <input
          value={p}
          onChange={(e) => setP(e.target.value)}
          type="password"
          className="w-full border rounded-xl px-3 py-2"
        />
      </div>
      {err && <div className="text-red-600 text-sm">{err}</div>}
      <button type="submit" className="w-full bg-black text-white rounded-xl px-3 py-2">Se connecter</button>
      <div className="text-xs text-gray-500 mt-2">Admin par defaut: admin / admin123</div>
    </form>
  );
}
