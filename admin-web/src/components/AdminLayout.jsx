import { Link, NavLink } from 'react-router-dom'
import { Activity, KeyRound, LayoutDashboard, Shield, Users } from 'lucide-react'

const links = [
  { to: '/', label: 'Overview', icon: LayoutDashboard },
  { to: '/citizens', label: 'Citizens', icon: Users },
  { to: '/agents', label: 'Agents', icon: KeyRound },
  { to: '/logs', label: 'Logs', icon: Activity },
  { to: '/security', label: 'Security', icon: Shield },
]

export default function AdminLayout({ title, children }) {
  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto flex max-w-7xl">
        <aside className="sticky top-0 hidden h-screen w-64 flex-col bg-gradient-to-b from-civic-700 to-civic-900 p-5 text-white lg:flex">
          <Link to="/" className="mb-8 text-2xl font-bold tracking-tight">
            BridgeID Admin
          </Link>
          <nav className="space-y-2">
            {links.map((l) => (
              <NavLink
                key={l.to}
                to={l.to}
                className={({ isActive }) =>
                  `flex items-center gap-3 rounded-xl px-3 py-2 transition-all duration-200 ${
                    isActive ? 'bg-white/20 shadow-soft' : 'hover:bg-white/10'
                  }`
                }
              >
                <l.icon size={18} />
                <span className="font-medium">{l.label}</span>
              </NavLink>
            ))}
          </nav>
        </aside>

        <main className="w-full p-4 lg:p-8">
          <header className="mb-5 rounded-2xl bg-white p-5 shadow-soft">
            <h1 className="text-2xl font-bold text-slate-900">{title}</h1>
          </header>
          {children}
        </main>
      </div>
    </div>
  )
}
