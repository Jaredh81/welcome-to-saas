import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase"; // adjust path if needed

type Property = { id: string; name: string; created_at: string };

export default function Properties({ orgId }: { orgId: string }) {
  const [items, setItems] = useState<Property[]>([]);
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    setLoading(true); setError(null);
    const { data, error } = await supabase
      .from("properties")
      .select("id, name, created_at")
      .eq("organisation_id", orgId)
      .order("created_at", { ascending: true });
    if (error) { setError(error.message); setItems([]); }
    else setItems(data ?? []);
    setLoading(false);
  }
  useEffect(() => { if (orgId) load(); }, [orgId]);

  async function createProperty() {
    const trimmed = name.trim(); if (!trimmed) return;
    setCreating(true); setError(null);
    const { error } = await supabase
      .from("properties")
      .insert({ name: trimmed, organisation_id: orgId });
    setCreating(false);
    if (error) return setError(error.message);
    setName(""); load();
  }

  return (
    <div className="mt-2 p-3 border border-gray-200 rounded-lg">
      <div className="flex gap-2 mb-2">
        <input
          name="propertyName"
          placeholder="New Property Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          id={`propertyName-${orgId}`}
        />
        <button
          onClick={createProperty}
          disabled={creating || !name.trim()}
          className={`px-4 py-2 rounded-md text-white text-sm font-medium ${creating ? "bg-gray-400 cursor-not-allowed" : "bg-indigo-600 hover:bg-indigo-700"}`}
        >
          {creating ? "Adding…" : "Add"}
        </button>
      </div>

      {loading ? (
        <div className="text-gray-500 text-sm">Loading properties…</div>
      ) : items.length === 0 ? (
        <div className="text-gray-500 text-sm">No properties yet.</div>
      ) : (
        <ul className="list-disc pl-5 space-y-1">
          {items.map((p) => (
            <li key={p.id}>{p.name}</li>
          ))}
        </ul>
      )}

      {error && <div className="text-red-600 text-sm mt-1">{error}</div>}
    </div>
  );
}
