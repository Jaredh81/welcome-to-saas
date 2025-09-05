import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles/app.css' // Import our custom app.css
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
