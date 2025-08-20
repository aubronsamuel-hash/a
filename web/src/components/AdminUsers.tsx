import React, { useEffect, useMemo, useState } from "react";
import type { UsersOrder, UsersListOut } from "../api";
import { fetchUsers, usersCacheKey, saveUsersCache, getUsersCache } from "../api";

const ORDERS: UsersOrder[] = ["created_desc","created_asc","username_asc","username_desc"];

export default function AdminUsers({ token }: { token: string }) {
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [order, setOrder] = useState<UsersOrder>("created_desc");
  const [data, setData] = useState<UsersListOut | null>(null);
  const [etag, setEtag] = useState<string | undefined>(undefined);
  const [fromCache, setFromCache] = useState(false);
  const cacheKey = useMemo(() => usersCacheKey(page, pageSize, order), [page, pageSize, order]);

  const load = async () => {
    setFromCache(false);
    const cached = getUsersCache(cacheKey);
    const prevTag = etag ?? cached?.meta?.etag;
    const { payload, etag: newTag, notModified } = await fetchUsers(token, page, pageSize, order, prevTag);
    if (notModified && cached) {
      setData(cached);
      setEtag(prevTag);
      setFromCache(true);
      return;
    }
    if (payload) {
      setData(payload);
      if (newTag) setEtag(newTag);
      saveUsersCache(cacheKey, payload);
    }
  };

  useEffect(() => {
    load().catch((e) => console.error("Erreur chargement users:", e));
  }, [page, pageSize, order, token]);

  const canPrev = (data?.meta?.page ?? 1) > 1;
  const canNext = data ? data.meta.page < data.meta.pages : false;

  return (
    <div className="bg-white shadow rounded-2xl p-6 space-y-4">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <label className="text-sm">Tri</label>
          <select value={order} onChange={(e) => setOrder(e.target.value as UsersOrder)} className="border rounded-xl px-2 py-1">
            {ORDERS.map(o => <option key={o} value={o}>{o}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-2">
          <label className="text-sm">Page size</label>
          <input type="number" min={1} max={200} value={pageSize} onChange={(e) => setPageSize(parseInt(e.target.value || "1"))} className="w-20 border rounded-xl px-2 py-1" />
        </div>
        <div className="text-xs text-gray-500">
          {fromCache ? "from cache" : "live"}
          {etag ? ` | etag ${etag.substring(0,8)}...` : ""}
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left border-b">
              <th className="py-2">ID</th>
              <th className="py-2">Username</th>
              <th className="py-2">Role</th>
            </tr>
          </thead>
          <tbody>
            {(data?.data ?? []).map(u => (
              <tr key={u.id} className="border-b last:border-b-0">
                <td className="py-2">{u.id}</td>
                <td className="py-2">{u.username}</td>
                <td className="py-2">{u.role}</td>
              </tr>
            ))}
            {(!data || data.data.length === 0) && (
              <tr><td className="py-4 text-gray-500" colSpan={3}>Aucun utilisateur</td></tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-600">
          {data ? `Total ${data.meta.total} | Page ${data.meta.page}/${data.meta.pages} | size ${data.meta.page_size}` : "Chargement..."}
        </div>
        <div className="flex items-center gap-2">
          <button disabled={!canPrev} onClick={() => setPage(p => Math.max(1, p-1))} className="px-3 py-2 rounded-xl border disabled:opacity-50">Prev</button>
          <button disabled={!canNext} onClick={() => setPage(p => p+1)} className="px-3 py-2 rounded-xl border disabled:opacity-50">Next</button>
        </div>
      </div>
    </div>
  );
}
