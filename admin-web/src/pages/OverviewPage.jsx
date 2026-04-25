import { useEffect, useState } from 'react'
import AdminLayout from '../components/AdminLayout'
import KpiCard from '../components/KpiCard'
import { fetchKpis } from '../lib/api'

export default function OverviewPage() {
  const [kpis, setKpis] = useState({})
  const [error, setError] = useState('')

  useEffect(() => {
    fetchKpis().then(setKpis).catch((e) => setError(e.message))
  }, [])

  return (
    <AdminLayout title="Overview">
      {error ? (
        <div className="rounded-2xl bg-rose-50 p-4 text-rose-700 shadow-soft">{error}</div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <KpiCard label="Users" value={kpis.users ?? 0} />
          <KpiCard label="Service Records" value={kpis.serviceRecords ?? 0} />
          <KpiCard label="Agent Scans" value={kpis.agentScans ?? 0} />
          <KpiCard label="Active Agent Keys" value={kpis.activeAgentKeys ?? 0} />
        </div>
      )}
    </AdminLayout>
  )
}
