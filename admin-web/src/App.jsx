import { Navigate, Route, Routes } from 'react-router-dom'
import OverviewPage from './pages/OverviewPage'
import CitizensPage from './pages/CitizensPage'
import AgentsPage from './pages/AgentsPage'
import LogsPage from './pages/LogsPage'
import SecurityPage from './pages/SecurityPage'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<OverviewPage />} />
      <Route path="/citizens" element={<CitizensPage />} />
      <Route path="/agents" element={<AgentsPage />} />
      <Route path="/logs" element={<LogsPage />} />
      <Route path="/security" element={<SecurityPage />} />
      <Route path="/settings" element={<SecurityPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
