import { useEffect, useState } from 'react'
import { Plus, Trash2 } from 'lucide-react'
import AdminLayout from '../components/AdminLayout'
import {
  createAgentKey,
  deleteAgentKey,
  disableAgentKey,
  enableAgentKey,
  fetchAgentKeys,
} from '../lib/api'

function formatDate(s) {
  if (!s) return '—'
  try {
    return new Date(s).toLocaleString()
  } catch {
    return s
  }
}

export default function AgentsPage() {
  const [keys, setKeys] = useState([])
  const [error, setError] = useState('')
  const [showCreate, setShowCreate] = useState(false)
  const [label, setLabel] = useState('')
  const [creating, setCreating] = useState(false)
  const [issued, setIssued] = useState(null) // { key_id, label, key }

  const load = () => fetchAgentKeys().then(setKeys).catch((e) => setError(e.message))

  useEffect(() => {
    load()
  }, [])

  async function toggleKey(k) {
    setError('')
    try {
      if (k.disabled) await enableAgentKey(k.id)
      else await disableAgentKey(k.id)
      await load()
    } catch (e) {
      setError(e.message)
    }
  }

  async function onCreate(e) {
    e.preventDefault()
    setCreating(true)
    setError('')
    try {
      const created = await createAgentKey(label.trim() || 'verifier device')
      setIssued(created)
      setLabel('')
      setShowCreate(false)
      await load()
    } catch (err) {
      setError(err.message)
    } finally {
      setCreating(false)
    }
  }

  async function onDelete(k) {
    if (!confirm(`Permanently delete agent key "${k.label}" (${k.key_id})? Verifier apps using it will stop working immediately.`)) return
    setError('')
    try {
      await deleteAgentKey(k.id)
      await load()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <AdminLayout title="Agents">
      <div className="rounded-2xl bg-white p-5 shadow-soft">
        <div className="mb-4 flex items-center justify-between">
          <p className="text-sm text-slate-600">
            Issue API keys to verifier devices (front-desk apps that scan citizen QR codes).
          </p>
          <button
            onClick={() => setShowCreate(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-civic-700 px-4 py-2 text-sm font-medium text-white hover:bg-civic-800"
          >
            <Plus size={16} /> New Agent Key
          </button>
        </div>

        {error && <p className="mb-3 text-sm text-rose-700">{error}</p>}

        <div className="space-y-2">
          {keys.map((k) => (
            <div
              key={k.id}
              className="flex items-center justify-between rounded-xl border border-slate-200 p-3"
            >
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <p className="font-semibold text-slate-900">{k.label || 'Agent Key'}</p>
                  {k.disabled && (
                    <span className="rounded-md bg-rose-100 px-2 py-0.5 text-xs font-medium text-rose-700">
                      Disabled
                    </span>
                  )}
                </div>
                <p className="font-mono text-xs text-slate-500">{k.key_id}</p>
                <p className="text-xs text-slate-400">Created {formatDate(k.created_at)}</p>
              </div>
              <div className="flex items-center gap-2">
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
                <button
                  onClick={() => onDelete(k)}
                  className="rounded-xl bg-slate-100 p-2 text-slate-600 hover:bg-rose-100 hover:text-rose-700"
                  title="Delete permanently"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
          {!keys.length && <p className="text-sm text-slate-500">No agent keys found.</p>}
        </div>
      </div>

      {showCreate && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setShowCreate(false)}
        >
          <form
            onSubmit={onCreate}
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-1 text-lg font-bold text-slate-900">New Agent Key</h3>
            <p className="mb-4 text-sm text-slate-600">
              Issue an API key for a verifier device. The secret is shown ONCE — copy it and put it in the verifier app config.
            </p>
            <label className="mb-1 block text-sm font-medium text-slate-700">Label</label>
            <input
              autoFocus
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="e.g. Casablanca Regional Office"
              className="mb-5 w-full rounded-xl border border-slate-200 px-3 py-2 text-sm focus:border-civic-500 focus:outline-none"
            />
            <div className="flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setShowCreate(false)}
                className="rounded-xl bg-slate-100 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-200"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={creating}
                className="rounded-xl bg-civic-700 px-4 py-2 text-sm font-medium text-white hover:bg-civic-800 disabled:opacity-60"
              >
                {creating ? 'Creating…' : 'Issue Key'}
              </button>
            </div>
          </form>
        </div>
      )}

      {issued && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setIssued(null)}
        >
          <div
            className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-2 text-lg font-bold text-slate-900">Agent key issued</h3>
            <p className="mb-4 text-sm text-slate-600">
              Copy the secret below — it will not be shown again. Configure the verifier app to send it as <span className="font-mono text-xs">Authorization: Bearer &lt;secret&gt;</span>.
            </p>
            <div className="mb-3 rounded-xl bg-slate-50 p-3">
              <p className="text-xs text-slate-500">Label</p>
              <p className="mb-2 font-medium text-slate-800">{issued.label}</p>
              <p className="text-xs text-slate-500">Key ID</p>
              <p className="font-mono text-sm text-slate-800">{issued.key_id}</p>
            </div>
            <div className="mb-4 rounded-xl border-2 border-amber-300 bg-amber-50 p-3">
              <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-amber-700">
                Secret (shown once)
              </p>
              <p className="break-all font-mono text-xs text-slate-900">{issued.key}</p>
            </div>
            <div className="flex justify-end gap-2">
              <button
                onClick={() => navigator.clipboard.writeText(issued.key)}
                className="rounded-xl bg-slate-100 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-200"
              >
                Copy Secret
              </button>
              <button
                onClick={() => setIssued(null)}
                className="rounded-xl bg-civic-700 px-4 py-2 text-sm font-medium text-white hover:bg-civic-800"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  )
}
