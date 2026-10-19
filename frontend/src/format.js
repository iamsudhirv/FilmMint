export function money(n) {
  if (n === null || n === undefined) return '—'
  const sign = n < 0 ? '-' : ''
  const v = Math.abs(n)
  if (v >= 1e6) return `${sign}$${(v / 1e6).toFixed(v >= 1e7 ? 0 : 1)}M`
  if (v >= 1e3) return `${sign}$${Math.round(v / 1e3)}K`
  return `${sign}$${v}`
}

export function signedMoney(n) {
  return (n > 0 ? '+' : '') + money(n)
}

export function label(s) {
  return (s || '').replace(/_/g, ' ')
}

export function verdictBadge(v) {
  return { strong: ['good', 'Strong value'], fair: ['warn', 'Fair value'], weak: ['bad', 'Fee above value'],
    no_data: ['neutral', 'No data'], unknown: ['neutral', 'Unknown'] }[v] || ['neutral', v]
}

export function riskClass(level) {
  return { low: 'good', medium: 'warn', high: 'bad' }[level] || 'neutral'
}

// One fixed colour per territory so it looks the same everywhere in the app.
const TERRITORY_COLORS = {
  'United States': '#60a5fa', 'United Kingdom': '#f472b6', France: '#a78bfa', Germany: '#fbbf24',
  Italy: '#34d399', Spain: '#fb923c', Japan: '#f87171', India: '#2dd4bf',
  'Latin America': '#a3e635', Balkans: '#c084fc', 'Russian-speaking': '#38bdf8', 'Australia / NZ': '#facc15',
  Pakistan: '#4ade80', Portugal: '#e879f9', 'Middle East': '#fdba74',
}

export function territoryColor(name) {
  return TERRITORY_COLORS[name] || '#d4d4d8'
}

const INDUSTRY_NAMES = {
  hollywood: 'Hollywood', bollywood: 'Bollywood', french: 'French', japanese: 'Japanese',
  pakistani: 'Pakistani', bhojpuri: 'Bhojpuri', portuguese: 'Portuguese',
}

export function industryName(key) {
  return INDUSTRY_NAMES[key] || label(key)
}

// Colour per role, used for the connection flow.
const KIND_COLORS = {
  producer: '#fbbf24', actor: '#f472b6', director: '#60a5fa', agent: '#a78bfa',
  sales_agent: '#34d399', cinematographer: '#fb923c', writer: '#f87171',
}

export function kindColor(kind) {
  return KIND_COLORS[kind] || '#d4d4d8'
}

export const KIND_LEGEND = Object.keys(KIND_COLORS)

export function capitalize(s) {
  return s ? s.charAt(0).toUpperCase() + s.slice(1) : s
}

// Colour tone of a change: is it good or bad for the producer? ("lowerIsBetter" for fees and risk)
export function tone(delta, lowerIsBetter = false) {
  if (!delta) return 'flat'
  return (delta < 0) === lowerIsBetter ? 'good' : 'bad'
}
