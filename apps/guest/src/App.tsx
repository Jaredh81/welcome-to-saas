import { BrowserRouter, Routes, Route } from 'react-router-dom';
import GuidePage from './components/GuidePage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/g/:slug" element={<GuidePage />} />
        {/* Add other routes here as needed */}
      </Routes>
    </BrowserRouter>
  );
}

export default App;
