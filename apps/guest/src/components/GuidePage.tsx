import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';

interface CardData {
  emoji: string;
  title: string;
}

interface GuideSnapshot {
  title: string;
  cards: CardData[];
}

function GuidePage() {
  const { slug } = useParams<{ slug: string }>();
  const [guide, setGuide] = useState<GuideSnapshot | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>(''); // New state for search term

  useEffect(() => {
    if (!slug) {
      setError('No slug provided.');
      setLoading(false);
      return;
    }

    async function fetchGuide() {
      try {
        const { data, error } = await supabase
          .from('published_guides')
          .select('snapshot_json')
          .eq('slug', slug)
          .single();

        if (error) {
          throw error;
        }

        if (data) {
          setGuide(data.snapshot_json as GuideSnapshot);
        } else {
          setError('Guide not found.');
        }
      } catch (err: any) {
        console.error('Error fetching guide:', err);
        setError(err.message || 'An unexpected error occurred.');
      } finally {
        setLoading(false);
      }
    }

    fetchGuide();
  }, [slug]);

  // Filtered cards based on search term
  const filteredCards = guide?.cards.filter(card =>
    card.title.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  if (loading) {
    return <div className="shell">Loading guide...</div>;
  }

  if (error) {
    return <div className="shell">Error: {error}</div>;
  }

  if (!guide) {
    return <div className="shell">No guide data available.</div>;
  }

  return (
    <div>
      <header className="top">
        <div className="top-wrapper">
          {/* The main app branding, if any, for the global top bar could go here. For M1, we focus on guide content. */}
        </div>
      </header>

      <div className="shell">
        <main className="content">
          <h1>{guide.title}</h1> {/* Moved guide.title into main content */}
          <div className="content-top">
            <div className="avatar"></div>
            <div className="search">
              <input
                type="text"
                placeholder="Search"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <div className="share">Share</div>
          </div>

          <div className="grid">
            {filteredCards.map((card, index) => (
              <div
                key={index}
                className="card"
                tabIndex={0} // Make card keyboard focusable
                onClick={() => console.log('Card clicked:', card.title)} // Placeholder for interaction
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    console.log('Card activated by keyboard:', card.title);
                  }
                }}
              >
                <span className="ico">{card.emoji}</span>
                <span className="ttl">{card.title}</span>
              </div>
            ))}
          </div>
        </main>

        <footer className="bottom">
          <div className="bottom-wrapper">
            {/* Bottom navigation will go here */}
            <button className="tab is-active">Guide</button>
          </div>
        </footer>
      </div>
    </div>
  );
}

export default GuidePage;
