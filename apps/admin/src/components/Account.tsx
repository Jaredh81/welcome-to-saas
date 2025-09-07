import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase"; // ← adjust this path if needed
import Properties from "./Properties"; // Add this import

type Org = {
  id: string;
  name: string;
  created_at: string;
};

export default function Account() {
  const [email, setEmail] = useState<string>("");
  const [orgName, setOrgName] = useState<string>("");
  const [orgs, setOrgs] = useState<Org[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [creating, setCreating] = useState<boolean>(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // Load session + orgs
  useEffect(() => {
    (async () => {
      setLoading(true);
      setErrorMsg(null);
      const { data: { user }, error } = await supabase.auth.getUser();
      if (error) {
        setErrorMsg(error.message);
        setLoading(false);
        return;
      }
      setEmail(user?.email ?? "");

      await refreshOrgs();
      setLoading(false);
    })();
  }, []);

  async function refreshOrgs() {
    setErrorMsg(null);
    const { data, error } = await supabase
      .from("organisations")
      .select("id, name, created_at")
      .order("created_at", { ascending: true });

    if (error) {
      console.error("Error fetching organizations:", error);
      setErrorMsg(error.message);
      setOrgs([]);
      return;
    }
    setOrgs(data ?? []);
  }

  async function handleCreateOrg() {
    const name = orgName.trim();
    if (!name) return;

    setCreating(true);
    setErrorMsg(null);

    // IMPORTANT: no insert into organisation_members here.
    const { error } = await supabase.from("organisations").insert({ name });

    setCreating(false);

    if (error) {
      // You might still see message text coming from a trigger/policy;
      // we just show it to the user cleanly.
      console.error("Create org error:", error);
      setErrorMsg(error.message);
      return;
    }

    setOrgName("");
    await refreshOrgs();
  }

  async function handleSignOut() {
    await supabase.auth.signOut();
    // Simple reload to clear local state/routes
    window.location.reload();
  }

  return (
    <div className="account-wrapper">
      <div className="account-card">
        <div style={{ marginBottom: 12 }}>
          <div className="account-email-info">
            <strong>Email:</strong><br />{email || "—"}
          </div>
          <button
            onClick={handleSignOut}
            className="account-signout-button"
          >
            Sign Out
          </button>
        </div>

        <h3 className="account-section-header">Your Organizations</h3>

        <input
          placeholder="New Organization Name"
          value={orgName}
          onChange={(e) => setOrgName(e.target.value)}
          className="account-input-field"
          id="orgName"
          name="orgName"
        />

        <button
          onClick={handleCreateOrg}
          disabled={creating || !orgName.trim()}
          className="account-create-button"
        >
          {creating ? "Creating…" : "Create Organization"}
        </button>

        {loading ? (
          <div className="account-loading">Loading…</div>
        ) : orgs.length === 0 ? (
          <div className="account-no-items">No organizations yet. Create one above!</div>
        ) : (
          <ul className="account-list">
            {orgs.map((o) => (
              <li key={o.id}>
                <div className="account-org-name">{o.name}</div>
                <Properties orgId={o.id} />
              </li>
            ))}
          </ul>
        )}

        {errorMsg && (
          <div className="account-error-message">
            {errorMsg}
          </div>
        )}
      </div>
    </div>
  );
}