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
  const isJsonBody = opts.body && typeof opts.body !== 'string'
  const res = await fetch(`${baseUrl}${path}`, {
    ...opts,
    headers: {
      ...headers(),
      ...(isJsonBody ? { 'Content-Type': 'application/json' } : {}),
      ...(opts.headers || {}),
    },
    body: isJsonBody ? JSON.stringify(opts.body) : opts.body,
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

export async function createAgentKey(label) {
  const json = await req('/admin/agent-keys', { method: 'POST', body: { label } })
  return json?.data?.key || null
}

export async function deleteAgentKey(id) {
  return req(`/admin/agent-keys/${id}`, { method: 'DELETE' })
}

export async function fetchCitizens({ search = '', limit = 100 } = {}) {
  const params = new URLSearchParams()
  if (search) params.set('search', search)
  params.set('limit', String(limit))
  const json = await req(`/admin/citizens?${params.toString()}`)
  return json?.data?.citizens || []
}

export async function lockCitizen(id) {
  return req(`/admin/citizens/${id}/lock`, { method: 'POST' })
}

export async function unlockCitizen(id) {
  return req(`/admin/citizens/${id}/unlock`, { method: 'POST' })
}

export async function resetCitizenPin(id) {
  const json = await req(`/admin/citizens/${id}/reset-pin`, { method: 'POST' })
  return json?.data?.citizen || null
}
