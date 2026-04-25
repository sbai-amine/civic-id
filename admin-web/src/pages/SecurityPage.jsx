import AdminLayout from '../components/AdminLayout'

export default function SecurityPage() {
  return (
    <AdminLayout title="Security">
      <div className="rounded-2xl bg-white p-5 shadow-soft">
        <h2 className="mb-2 text-lg font-semibold text-slate-900">Security Controls</h2>
        <ul className="list-disc space-y-2 pl-5 text-slate-700">
          <li>Admin JWT rotation and expiry controls</li>
          <li>Agent key revoke/enable workflows</li>
          <li>Audit log inspection and incident review</li>
        </ul>
      </div>
    </AdminLayout>
  )
}
