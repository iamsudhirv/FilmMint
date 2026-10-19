<script setup>
import { ref, computed, onMounted } from 'vue'
import { api } from '../api/client'
import { money, signedMoney, label, verdictBadge, riskClass, territoryColor, industryName, capitalize, tone } from '../format'

const props = defineProps({ id: String })

const project = ref(null)
const valuation = ref(null)
const people = ref([])
const search = ref('')
const error = ref(null)
const busy = ref(false)

const swapOut = ref(null)
const swapIn = ref(null)
const scenario = ref(null)

const memberIds = computed(() => new Set((project.value?.members || []).map((m) => m.person_id)))
const results = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return []
  return people.value.filter((p) => !memberIds.value.has(p.id) && p.name.toLowerCase().includes(q)).slice(0, 6)
})
const candidates = computed(() => people.value.filter((p) => !memberIds.value.has(p.id) && p.kind !== 'agent' && p.kind !== 'sales_agent'))
const maxTerritory = computed(() => Math.max(1, ...(valuation.value?.territories || []).map((t) => t.estimate_usd)))
const risk = computed(() => valuation.value?.risk)

async function run(fn) {
  busy.value = true
  error.value = null
  try {
    await fn()
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  } finally {
    busy.value = false
  }
}

async function load() {
  project.value = (await api.get(`/projects/${props.id}`)).data
  valuation.value = (await api.get(`/projects/${props.id}/valuation`)).data
}

const addPerson = (person) => run(async () => {
  await api.post(`/projects/${props.id}/package_members`, { person_id: person.id, role: person.kind })
  search.value = ''
  scenario.value = null
  await load()
})

const removeMember = (m) => run(async () => {
  await api.delete(`/projects/${props.id}/package_members/${m.id}`)
  scenario.value = null
  await load()
})

const setStatus = (e) => run(async () => {
  await api.patch(`/projects/${props.id}`, { project: { status: e.target.value } })
  await load()
})

const setLeaning = (e) => run(async () => {
  await api.patch(`/projects/${props.id}`, { project: { political_leaning: e.target.value } })
  await load()
})

const compare = () => run(async () => {
  const params = {}
  if (swapOut.value) params.remove_person_id = swapOut.value
  if (swapIn.value) params.add_person_id = swapIn.value
  scenario.value = (await api.get(`/projects/${props.id}/valuation/what_if`, { params })).data
})

const applyScenario = () => run(async () => {
  const out = project.value.members.find((m) => m.person_id === swapOut.value)
  const incoming = people.value.find((p) => p.id === swapIn.value)
  if (out) await api.delete(`/projects/${props.id}/package_members/${out.id}`)
  if (incoming) {
    await api.post(`/projects/${props.id}/package_members`, { person_id: incoming.id, role: out?.role || incoming.kind })
  }
  swapOut.value = swapIn.value = scenario.value = null
  await load()
})

onMounted(() => run(async () => {
  people.value = (await api.get('/people')).data
  await load()
}))
</script>

<template>
  <p><RouterLink to="/projects">← Projects</RouterLink></p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-if="!project && !error">Loading…</p>

  <template v-if="project">
    <header class="head">
      <div>
        <h1>{{ project.title }}</h1>
        <p class="muted">{{ project.logline }}</p>
        <p>
          <span class="badge neutral">{{ capitalize(project.genre) || 'No genre' }}</span>
          <span class="badge neutral">Budget {{ money(project.budget_usd) }}</span>
        </p>
      </div>
      <div class="controls">
        <div>
          <label for="stage">Stage</label>
          <select id="stage" :value="project.status" @change="setStatus">
            <option value="development">Development</option><option value="financing">Financing</option>
            <option value="pre_production">Pre-Production</option><option value="production">Production</option>
            <option value="post">Post / Released</option>
          </select>
        </div>
        <div>
        <label for="lean">Story's political leaning</label>
        <select id="lean" :value="project.political_leaning" @change="setLeaning">
          <option value="none">Neutral / none</option><option value="left">Left-leaning</option>
          <option value="center">Centrist</option><option value="right">Right-leaning</option>
        </select>
        </div>
      </div>
    </header>

    <div class="grid two">
      <section class="card">
        <h2>Package</h2>
        <p v-if="!project.members.length" class="muted">Add actors, a director and key crew to see their value.</p>
        <table v-else>
          <tbody>
            <tr v-for="m in project.members" :key="m.id">
              <td><RouterLink :to="{ name: 'person', params: { id: m.person_id } }">{{ m.name }}</RouterLink>
                <div class="muted">{{ label(m.role) }}</div></td>
              <td>{{ money(m.fee_usd) }}</td>
              <td><button class="btn small secondary" :disabled="busy" @click="removeMember(m)">Remove</button></td>
            </tr>
          </tbody>
        </table>
        <label for="s" style="margin-top: 14px">Add a person</label>
        <input id="s" v-model="search" placeholder="Type a name…" style="width: 100%" />
        <ul class="results" v-if="results.length">
          <li v-for="p in results" :key="p.id">
            <span>{{ p.name }} <span class="muted">· {{ label(p.kind) }} · {{ industryName(p.industry) }} · {{ money(p.fee_usd) }}</span></span>
            <button class="btn small" :disabled="busy" @click="addPerson(p)">Add</button>
          </li>
        </ul>
      </section>

      <section class="card" v-if="valuation">
        <h2>At a glance</h2>
        <div class="stats">
          <div><div class="stat">{{ money(valuation.totals.expected_presales_usd) }}</div><div class="muted">Estimated presales</div></div>
          <div><div class="stat">{{ money(valuation.totals.total_fees_usd) }}</div><div class="muted">Package fees</div></div>
          <div>
            <div class="stat">{{ valuation.totals.budget_coverage != null ? Math.round(valuation.totals.budget_coverage * 100) + '%' : '—' }}</div>
            <div class="muted">Of budget covered</div>
          </div>
          <div>
            <div class="stat"><span :class="['badge', riskClass(risk.level)]" style="font-size: 1rem">{{ risk.level }} risk</span></div>
            <div class="muted">Score {{ risk.score }}/100</div>
          </div>
        </div>
        <ul v-if="risk.notes.length" class="notes">
          <li v-for="n in risk.notes" :key="n">{{ n }}</li>
        </ul>
        <p v-else class="muted">No risk flags raised.</p>
        <p class="muted small">{{ valuation.disclaimer }}</p>
      </section>
    </div>

    <section v-if="valuation && valuation.members.length" class="card" style="margin-top: 16px">
      <h2>Is each person worth their fee?</h2>
      <table>
        <thead><tr><th>Person</th><th>Fee</th><th>Expected sales</th><th>Return</th><th>Best territories</th></tr></thead>
        <tbody>
          <tr v-for="m in valuation.members" :key="m.person_id">
            <td><strong>{{ m.name }}</strong><div class="muted">{{ label(m.role) }}</div></td>
            <td>{{ money(m.fee_usd) }}</td>
            <td>{{ money(m.expected_sales_usd) }}</td>
            <td>
              <span :class="['badge', verdictBadge(m.verdict)[0]]">{{ verdictBadge(m.verdict)[1] }}</span>
              <div v-if="m.value_ratio" class="muted">{{ m.value_ratio }}× fee</div>
            </td>
            <td class="muted">{{ m.top_territories.map((t) => t.territory).join(', ') || '—' }}</td>
          </tr>
        </tbody>
      </table>
    </section>

    <section v-if="valuation && valuation.members.length" class="card" style="margin-top: 16px">
      <h2>Sales potential by territory</h2>
      <p class="muted">Estimated up-front sale value per territory for this package.</p>
      <div v-for="t in valuation.territories" :key="t.territory_id" class="bar-row">
        <span class="bar-label"><i class="dot" :style="{ background: territoryColor(t.territory) }" />{{ t.territory }}</span>
        <span class="bar"><span :style="{ width: (t.estimate_usd / maxTerritory) * 100 + '%', background: territoryColor(t.territory) }" /></span>
        <span class="bar-val">{{ money(t.estimate_usd) }}</span>
        <span class="muted contrib">{{ t.contributors.map((c) => c.name).join(', ') }}</span>
      </div>
    </section>

    <section v-if="valuation && valuation.members.length" class="card" style="margin-top: 16px">
      <h2>What if I change the package?</h2>
      <p class="muted">Swap someone out, add someone new, or both, and compare before you commit.</p>
      <div class="swap">
        <div>
          <label for="out">Replace</label>
          <select id="out" v-model="swapOut">
            <option :value="null">Nobody (just add)</option>
            <option v-for="m in project.members" :key="m.id" :value="m.person_id">{{ m.name }}</option>
          </select>
        </div>
        <div>
          <label for="in">With</label>
          <select id="in" v-model="swapIn">
            <option :value="null">Nobody (just remove)</option>
            <option v-for="p in candidates" :key="p.id" :value="p.id">{{ p.name }} ({{ label(p.kind) }})</option>
          </select>
        </div>
        <button class="btn" :disabled="busy || (!swapOut && !swapIn)" @click="compare">Compare</button>
      </div>

      <div v-if="scenario" class="compare">
        <h3>Result of this change</h3>
        <div class="deltas">
          <div :class="['delta-card', 'tone-' + tone(scenario.delta.expected_presales_usd)]">
            <div class="muted small">Estimated presales</div>
            <div class="stat">{{ money(scenario.scenario.totals.expected_presales_usd) }}</div>
            <div class="delta">{{ scenario.delta.expected_presales_usd > 0 ? '▲' : scenario.delta.expected_presales_usd < 0 ? '▼' : '•' }} {{ signedMoney(scenario.delta.expected_presales_usd) }}</div>
          </div>
          <div :class="['delta-card', 'tone-' + tone(scenario.delta.total_fees_usd, true)]">
            <div class="muted small">Package fees</div>
            <div class="stat">{{ money(scenario.scenario.totals.total_fees_usd) }}</div>
            <div class="delta">{{ scenario.delta.total_fees_usd > 0 ? '▲' : scenario.delta.total_fees_usd < 0 ? '▼' : '•' }} {{ signedMoney(scenario.delta.total_fees_usd) }}</div>
          </div>
          <div :class="['delta-card', 'tone-' + tone(scenario.delta.risk_score, true)]">
            <div class="muted small">Risk</div>
            <div class="stat">{{ scenario.scenario.risk.level }}</div>
            <div class="delta">{{ scenario.delta.risk_score > 0 ? '▲' : scenario.delta.risk_score < 0 ? '▼' : '•' }} {{ scenario.delta.risk_score > 0 ? '+' : '' }}{{ scenario.delta.risk_score }} score ({{ scenario.scenario.risk.score }}/100)</div>
          </div>
        </div>
        <ul class="notes"><li v-for="n in scenario.scenario.risk.notes" :key="n">{{ n }}</li></ul>
        <button class="btn" :disabled="busy" @click="applyScenario">Apply this change to the package</button>
      </div>
    </section>
  </template>
</template>

<style scoped>
.head { display: flex; justify-content: space-between; gap: 24px; flex-wrap: wrap; align-items: flex-start; }
.badge { margin-right: 6px; }
.two { grid-template-columns: 1fr 1fr; align-items: start; }
.results { list-style: none; padding: 0; margin: 8px 0 0; border: 1px solid var(--line); border-radius: 8px; }
.results li { display: flex; justify-content: space-between; align-items: center; padding: 8px 10px; border-bottom: 1px solid var(--line); }
.results li:last-child { border: 0; }
.stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 14px; margin-bottom: 12px; }
.stat { font-family: var(--font-display); font-size: 1.5rem; font-weight: 700; }
.notes { padding-left: 20px; }
.notes li { margin: 4px 0; }
.small { font-size: .85rem; }
.bar-row { display: grid; grid-template-columns: 140px 1fr 70px 200px; gap: 10px; align-items: center; margin: 7px 0; }
.bar { background: var(--neutral-bg); border-radius: 6px; height: 16px; overflow: hidden; }
.bar span { display: block; height: 100%; background: var(--brand); }
.bar-label { display: flex; align-items: center; gap: 8px; }
.dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.bar-val { text-align: right; font-variant-numeric: tabular-nums; }
.contrib { font-size: .85rem; }
.swap { display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap; }
.swap select { min-width: 240px; }
.compare { margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--line); }
.deltas { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 14px; margin-bottom: 14px; }
.delta-card { border: 2px solid; border-radius: 10px; padding: 12px 16px; }
.delta { font-weight: 700; margin-top: 2px; }
.tone-good { border-color: var(--ok); background: rgba(74, 222, 128, 0.1); }
.tone-good .delta { color: var(--ok); }
.tone-bad { border-color: var(--danger); background: rgba(248, 113, 113, 0.1); }
.tone-bad .delta { color: var(--danger); }
.tone-flat { border-color: rgba(255,255,255,.3); }
.controls { display: flex; gap: 16px; flex-wrap: wrap; }
@media (max-width: 800px) { .two { grid-template-columns: 1fr; } .bar-row { grid-template-columns: 110px 1fr 60px; } .contrib { display: none; } }
</style>
