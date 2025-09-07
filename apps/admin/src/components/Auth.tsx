import { useState } from 'react';
import { supabase } from '../lib/supabase';

function Auth() {
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');

  const handleLogin = async (event: React.FormEvent) => {
    event.preventDefault();

    setLoading(true);
    const { error } = await supabase.auth.signInWithOtp({ email });

    if (error) {
      alert(error.message);
    } else {
      alert('Check your email for a magic link!');
    }
    setLoading(false);
  };

  return (
    <div className="row flex-center flex-column">
      <div className="col-6 form-widget">
        <h1 className="header">Supabase + React</h1>
        <p className="description">Sign in via magic link with your email below</p>
        <form className="flex-column" onSubmit={handleLogin}>
          <input
            className="inputField"
            type="email"
            placeholder="Your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            name="email"
          />
          <button className="button block" disabled={loading}>
            {loading ? 'Loading' : 'Send magic link'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default Auth;
