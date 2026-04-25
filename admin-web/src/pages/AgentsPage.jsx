import { useEffect, useState } from 'react'
import AdminLayout from '../components/AdminLayout'
import { disableAgentKey, enableAgentKey, fetchAgentKeys } from '../lib/api'

export default function AgentsPage() {
  const [keys, setKeys] = useState([])
  const [error, setError] = useState('')

  const load = () => fetchAgentKeys().then(setKeys).catch((e) => setError(e.message))

  useEffect(() => {
    load()
  }, [])

  async function toggleKey(k) {
    try {
      if (k.disabled) await enableAgentKey(k.id)
      else await disableAgentKey(k.id)
      await load()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <AdminLayout title="Agents">
      <div className="rounded-2xl bg-white p-4 shadow-soft">
        {error && <p className="mb-3 text-sm text-rose-700">{error}</p>}
        <div className="space-y-2">
          {keys.map((k) => (
            <div
              key={k.id}
              className="flex items-center justify-between rounded-xl border border-slate-200 p-3"
            >
              <div>
                <p className="font-semibold text-slate-900">{k.label || 'Agent Key'}</p>
                <p className="text-xs text-slate-500">{k.key_id}</p>
              </div>
              <button
                onClick={() => toggleKey(k)}
                className={`rounded-xl px-3 py-2 text-sm font-medium transition-all duration-200 ${
                  k.disabled
                    ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200'
                    : 'bg-rose-100 text-rose-700 hover:bg-rose-200'
                }`}
              >
                {k.disabled ? 'Enable' : 'Disable'}
              </button>
            </div>
          ))}
          {!keys.length && <p className="text-sm text-slate-500">No agent keys found.</p>}
        </div>
      </div>
    </AdminLayout>
  )
}
