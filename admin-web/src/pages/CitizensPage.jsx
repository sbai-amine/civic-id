import AdminLayout from '../components/AdminLayout'

export default function CitizensPage() {
  return (
    <AdminLayout title="Citizens">
      <div className="rounded-2xl bg-white p-5 shadow-soft">
        <p className="text-slate-700">
          Citizen management surface placeholder. Connect this to future endpoints for citizen
          account operations and support workflows.
        </p>
      </div>
    </AdminLayout>
  )
}
