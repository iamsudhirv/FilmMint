<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '../api/client'
import { money, label, riskClass, capitalize } from '../format'

const router = useRouter()
const projects = ref([])
const loading = ref(true)
const error = ref(null)
const showForm = ref(false)
const form = ref({ title: '', genre: '', budget_usd: '', political_leaning: 'none' })
const creating = ref(false)
const stageFilter = ref('')
const sortKey = ref('updated_at')
const sortDir = ref(-1)

const columns = [
  ['title', 'Project'], ['genre', 'Genre'], ['status', 'Stage'], ['budget_usd', 'Budget'],
  ['member_count', 'Package'], ['expected_presales_usd', 'Est. presales'], ['risk_score', 'Risk'], ['updated_at', 'Updated'],
]

const rows = computed(() => {
  const list = projects.value.filter((p) => !stageFilter.value || p.status === stageFilter.value)
  const k = sortKey.value
  return [...list].sort((a, b) => {
    const x = a[k] ?? -1, y = b[k] ?? -1
    return (x > y ? 1 : x < y ? -1 : 0) * sortDir.value
  })
})

function sortBy(key) {
  sortDir.value = sortKey.value === key ? -sortDir.value : 1
  sortKey.value = key
}

async function load() {
  try {
    projects.value = (await api.get('/projects')).data
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

async function create() {
  creating.value = true
  error.value = null
  try {
    const budget = form.value.budget_usd ? Number(form.value.budget_usd) * 1_000_000 : null
    const { data } = await api.post('/projects', { project: { ...form.value, budget_usd: budget } })
    router.push({ name: 'project', params: { id: data.id } })
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  } finally {
    creating.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="head">
    <div>
      <h1>Projects</h1>
      <p class="muted">Open a project to build its package and check value and risk.</p>
    </div>
    <button class="btn" @click="showForm = !showForm">{{ showForm ? 'Close' : '+ New project' }}</button>
  </div>
  <p v-if="error" class="error">{{ error }}</p>

  <form v-if="showForm" class="card form" @submit.prevent="create">
    <div><label for="t">Title</label><input id="t" v-model="form.title" required /></div>
    <div><label for="g">Genre</label>
      <select id="g" v-model="form.genre">
        <option value="">Choose…</option>
        <option v-for="g in ['action','comedy','crime','drama','horror','romance','sci-fi','thriller']" :key="g" :value="g">{{ capitalize(g) }}</option>
      </select></div>
    <div><label for="b">Budget (millions USD)</label>
      <input id="b" v-model="form.budget_usd" type="number" min="0.1" max="2000" step="0.1" placeholder="e.g. 15 for $15M" /></div>
    <div><label for="l">Story's political leaning</label>
      <select id="l" v-model="form.political_leaning">
        <option value="none">Neutral / none</option><option value="left">Left-leaning</option>
        <option value="center">Centrist</option><option value="right">Right-leaning</option>
      </select></div>
    <button class="btn" :disabled="creating">Create project</button>
  </form>

  <p>
    <select v-model="stageFilter">
      <option value="">All stages</option>
      <option v-for="s in ['development','financing','pre_production','production','post']" :key="s" :value="s">{{ label(s) }}</option>
    </select>
    <span class="muted" style="margin-left: 12px">{{ rows.length }} project{{ rows.length === 1 ? '' : 's' }}</span>
  </p>

  <p v-if="loading">Loading…</p>
  <div v-else class="card table-wrap">
    <table>
      <thead>
        <tr>
          <th v-for="[key, title] in columns" :key="key" class="sortable" @click="sortBy(key)">
            {{ title }}<span v-if="sortKey === key"> {{ sortDir === 1 ? '▲' : '▼' }}</span>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="p in rows" :key="p.id" class="row" @click="router.push({ name: 'project', params: { id: p.id } })">
          <td><RouterLink :to="{ name: 'project', params: { id: p.id } }" @click.stop><strong>{{ p.title }}</strong></RouterLink>
            <div class="muted small">{{ p.logline }}</div></td>
          <td>{{ capitalize(p.genre) || '—' }}</td>
          <td><span class="badge neutral">{{ label(p.status) }}</span></td>
          <td>{{ money(p.budget_usd) }}</td>
          <td>{{ p.member_count }}</td>
          <td>{{ p.member_count ? money(p.expected_presales_usd) : '—' }}</td>
          <td><span v-if="p.risk_level" :class="['badge', riskClass(p.risk_level)]">{{ p.risk_level }} · {{ p.risk_score }}</span><span v-else class="muted">—</span></td>
          <td class="muted">{{ new Date(p.updated_at).toLocaleDateString() }}</td>
        </tr>
        <tr v-if="!rows.length"><td colspan="8" class="muted">No projects match.</td></tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; flex-wrap: wrap; }
.form { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; align-items: end; margin-bottom: 16px; }
.form input, .form select { width: 100%; }
.table-wrap { padding: 0; overflow-x: auto; }
.sortable { cursor: pointer; user-select: none; white-space: nowrap; }
.sortable:hover { color: #fff; }
.row { cursor: pointer; }
.row:hover { background: var(--neutral-bg); }
.small { font-size: .85rem; max-width: 280px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
</style>
