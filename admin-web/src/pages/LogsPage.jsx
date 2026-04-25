import { useEffect, useState } from 'react'
import AdminLayout from '../components/AdminLayout'
import { fetchAuditLogs } from '../lib/api'

export default function LogsPage() {
  const [logs, setLogs] = useState([])
  const [error, setError] = useState('')

  useEffect(() => {
    fetchAuditLogs(100).then(setLogs).catch((e) => setError(e.message))
  }, [])

  return (
    <AdminLayout title="Logs">
      <div className="rounded-2xl bg-white p-4 shadow-soft">
        {error && <p className="mb-3 text-sm text-rose-700">{error}</p>}
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b border-slate-200 text-left text-slate-500">
                <th className="py-2">Action</th>
                <th className="py-2">Actor</th>
                <th className="py-2">Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {logs.map((l) => (
                <tr key={l.id} className="border-b border-slate-100">
                  <td className="py-2 font-medium text-slate-800">{l.action}</td>
                  <td className="py-2 text-slate-600">
                    {l.actor_type}
                    {l.actor_ref ? ` (${l.actor_ref})` : ''}
                  </td>
                  <td className="py-2 text-slate-500">{l.created_at}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
