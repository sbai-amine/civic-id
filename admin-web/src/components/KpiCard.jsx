export default function KpiCard({ label, value }) {
  return (
    <div className="rounded-2xl bg-white p-5 shadow-soft">
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-2 text-3xl font-bold text-slate-900">{value}</p>
    </div>
  )
}
