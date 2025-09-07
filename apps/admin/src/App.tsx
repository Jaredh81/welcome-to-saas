import { useState, useEffect } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import { supabase } from './lib/supabase';
import Auth from './components/Auth';
import Account from './components/Account';

function App() {
  const [session, setSession] = useState<any | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (!session) {
        navigate('/auth'); // Redirect to auth page if no session
      }
    });
  }, []);

  return (
    <div className="shell">
      <main className="content">
        <Routes>
          <Route path="/auth" element={<Auth />} />
          <Route path="/" element={session ? <Account key={session.user.id} session={session} /> : <Auth />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;
