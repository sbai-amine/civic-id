import { useEffect, useState } from 'react'
import { Lock, RotateCcw, Search, Unlock } from 'lucide-react'
import AdminLayout from '../components/AdminLayout'
import { fetchCitizens, lockCitizen, resetCitizenPin, unlockCitizen } from '../lib/api'

function isLocked(c) {
  if (!c?.locked_until) return false
  return new Date(c.locked_until).getTime() > Date.now()
}

function formatDate(s) {
  if (!s) return '—'
  try {
    return new Date(s).toLocaleString()
  } catch {
    return s
  }
}

export default function CitizensPage() {
  const [citizens, setCitizens] = useState([])
  const [search, setSearch] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [busyId, setBusyId] = useState(null)
  const [pinModal, setPinModal] = useState(null) // { nationalId, tempPin }

  async function load(s = search) {
    setLoading(true)
    setError('')
    try {
      const rows = await fetchCitizens({ search: s, limit: 200 })
      setCitizens(rows)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    load('')
  }, [])

  async function onLock(c) {
    setBusyId(c.id)
    setError('')
    try {
      await lockCitizen(c.id)
      await load()
    } catch (e) {
      setError(e.message)
    } finally {
      setBusyId(null)
    }
  }

  async function onUnlock(c) {
    setBusyId(c.id)
    setError('')
    try {
      await unlockCitizen(c.id)
      await load()
    } catch (e) {
      setError(e.message)
    } finally {
      setBusyId(null)
    }
  }

  async function onReset(c) {
    if (!confirm(`Reset PIN for ${c.national_id}? A new temporary PIN will be generated.`)) return
    setBusyId(c.id)
    setError('')
    try {
      const result = await resetCitizenPin(c.id)
      if (result?.tempPin) {
        setPinModal({ nationalId: c.national_id, tempPin: result.tempPin })
      }
      await load()
    } catch (e) {
      setError(e.message)
    } finally {
      setBusyId(null)
    }
  }

  return (
    <AdminLayout title="Citizens">
      <div className="rounded-2xl bg-white p-5 shadow-soft">
        <form
          onSubmit={(e) => {
            e.preventDefault()
            load()
          }}
          className="mb-4 flex items-center gap-2"
        >
          <div className="relative flex-1">
            <Search
              size={16}
              className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
            />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by national ID or name…"
              className="w-full rounded-xl border border-slate-200 bg-white px-9 py-2 text-sm focus:border-civic-500 focus:outline-none"
            />
          </div>
          <button
            type="submit"
            className="rounded-xl bg-civic-700 px-4 py-2 text-sm font-medium text-white hover:bg-civic-800"
          >
            Search
          </button>
        </form>

        {error && <p className="mb-3 text-sm text-rose-700">{error}</p>}

        {loading && <p className="text-sm text-slate-500">Loading…</p>}

        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b border-slate-200 text-left text-slate-500">
                <th className="py-2 pr-3">National ID</th>
                <th className="py-2 pr-3">Full Name</th>
                <th className="py-2 pr-3">Created</th>
                <th className="py-2 pr-3">Status</th>
                <th className="py-2 pr-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {citizens.map((c) => {
                const locked = isLocked(c)
                return (
                  <tr key={c.id} className="border-b border-slate-100">
                    <td className="py-3 pr-3 font-mono text-slate-800">{c.national_id}</td>
                    <td className="py-3 pr-3 text-slate-700">{c.full_name || '—'}</td>
                    <td className="py-3 pr-3 text-slate-500">{formatDate(c.created_at)}</td>
                    <td className="py-3 pr-3">
                      {locked ? (
                        <span className="inline-flex items-center gap-1 rounded-md bg-rose-100 px-2 py-0.5 text-xs font-medium text-rose-700">
                          <Lock size={12} /> Locked
                        </span>
                      ) : c.failed_login_attempts > 0 ? (
                        <span className="inline-flex items-center gap-1 rounded-md bg-amber-100 px-2 py-0.5 text-xs font-medium text-amber-700">
                          {c.failed_login_attempts} failed
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 rounded-md bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-700">
                          Active
                        </span>
                      )}
                    </td>
                    <td className="py-3 pr-3">
                      <div className="flex justify-end gap-2">
                        {locked ? (
                          <button
                            disabled={busyId === c.id}
                            onClick={() => onUnlock(c)}
                            className="inline-flex items-center gap-1 rounded-lg bg-emerald-100 px-2.5 py-1.5 text-xs font-medium text-emerald-700 hover:bg-emerald-200 disabled:opacity-50"
                          >
                            <Unlock size={13} /> Unlock
                          </button>
                        ) : (
                          <button
                            disabled={busyId === c.id}
                            onClick={() => onLock(c)}
                            className="inline-flex items-center gap-1 rounded-lg bg-rose-100 px-2.5 py-1.5 text-xs font-medium text-rose-700 hover:bg-rose-200 disabled:opacity-50"
                          >
                            <Lock size={13} /> Lock
                          </button>
                        )}
                        <button
                          disabled={busyId === c.id}
                          onClick={() => onReset(c)}
                          className="inline-flex items-center gap-1 rounded-lg bg-slate-100 px-2.5 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-200 disabled:opacity-50"
                        >
                          <RotateCcw size={13} /> Reset PIN
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
              {!loading && !citizens.length && (
                <tr>
                  <td colSpan={5} className="py-6 text-center text-sm text-slate-500">
                    No citizens found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {pinModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setPinModal(null)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-2 text-lg font-bold text-slate-900">Temporary PIN issued</h3>
            <p className="mb-4 text-sm text-slate-600">
              Share this PIN with citizen <span className="font-mono">{pinModal.nationalId}</span>.
              They must sign in and change it immediately. This PIN will not be shown again.
            </p>
            <div className="mb-4 rounded-xl border-2 border-emerald-300 bg-emerald-50 p-4 text-center">
              <p className="font-mono text-3xl font-bold tracking-[0.5em] text-emerald-800">
                {pinModal.tempPin}
              </p>
            </div>
            <div className="flex justify-end gap-2">
              <button
                onClick={() => navigator.clipboard.writeText(pinModal.tempPin)}
                className="rounded-xl bg-slate-100 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-200"
              >
                Copy PIN
              </button>
              <button
                onClick={() => setPinModal(null)}
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
