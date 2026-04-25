const baseUrl = (import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:3000').replace(/\/+$/, '')
const adminKey = (import.meta.env.VITE_ADMIN_API_KEY || '').trim()

function headers() {
  if (!adminKey) throw new Error('Missing VITE_ADMIN_API_KEY')
  return {
    Accept: 'application/json',
    Authorization: `Bearer ${adminKey}`,
  }
}

async function req(path, opts = {}) {
  const res = await fetch(`${baseUrl}${path}`, {
    ...opts,
    headers: {
      ...headers(),
      ...(opts.headers || {}),
    },
  })
  const json = await res.json().catch(() => ({}))
  if (!res.ok || json.success === false) {
    const msg = json?.error?.message || `Request failed (${res.status})`
    throw new Error(msg)
  }
  return json
}

export async function fetchKpis() {
  const json = await req('/admin/kpis')
  return json?.data?.kpis || {}
}

export async function fetchAgentKeys() {
  const json = await req('/admin/agent-keys')
  return json?.data?.keys || []
}

export async function fetchAuditLogs(limit = 100) {
  const json = await req(`/admin/audit-logs?limit=${limit}`)
  return json?.data?.logs || []
}

export async function disableAgentKey(id) {
  return req(`/admin/agent-keys/${id}/disable`, { method: 'POST' })
}

export async function enableAgentKey(id) {
  return req(`/admin/agent-keys/${id}/enable`, { method: 'POST' })
}
