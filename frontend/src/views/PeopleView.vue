<script setup>
import { ref, watch, onMounted } from 'vue'
import { api } from '../api/client'
import { money, label, industryName } from '../format'

const people = ref([])
const q = ref('')
const kind = ref('')
const industry = ref('')
const source = ref('')
const industries = ref([])
const loading = ref(true)
const error = ref(null)
let timer

async function load() {
  loading.value = true
  try {
    people.value = (await api.get('/people', { params: { q: q.value, kind: kind.value, industry: industry.value, source: source.value } })).data
    error.value = null
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

watch([q, kind, industry, source], () => { clearTimeout(timer); timer = setTimeout(load, 250) })
onMounted(async () => {
  industries.value = (await api.get('/industries')).data
  load()
})
</script>

<template>
  <h1>People</h1>
  <p class="muted">Search the industry. Open a person to see their "card": where their films have sold.</p>
  <p>
    <input v-model="q" placeholder="Search by name…" style="width: 280px" />
    <select v-model="industry" style="margin-left: 10px">
      <option value="">All industries</option>
      <option v-for="i in industries" :key="i.key" :value="i.key">{{ i.label }}</option>
    </select>
    <select v-model="source" style="margin-left: 10px">
      <option value="">Real and demo</option>
      <option value="wikidata">Real only</option>
      <option value="demo">Demo only</option>
    </select>
    <select v-model="kind" style="margin-left: 10px">
      <option value="">All roles</option>
      <option v-for="k in ['actor','director','producer','cinematographer','agent','sales_agent']" :key="k" :value="k">{{ label(k) }}</option>
    </select>
  </p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-else-if="loading">Loading…</p>
  <div v-else class="grid list">
    <RouterLink v-for="p in people" :key="p.id" :to="{ name: 'person', params: { id: p.id } }" class="card person">
      <h3>{{ p.name }}</h3>
      <span class="badge neutral">{{ label(p.kind) }}</span>
      <span class="badge neutral" style="margin-left: 6px">{{ industryName(p.industry) }}</span>
      <span :class="['badge', p.source === 'wikidata' ? 'good' : 'neutral']" style="margin-left: 6px">{{ p.source === 'wikidata' ? 'Real' : 'Demo' }}</span>
      <span v-if="p.nationality" class="muted"> · {{ p.nationality }}</span>
      <p v-if="p.fee_usd" class="muted">Asking fee {{ money(p.fee_usd) }}</p>
    </RouterLink>
    <p v-if="!people.length" class="muted">No one matches.</p>
  </div>
</template>

<style scoped>
.list { grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); }
.person { text-decoration: none; color: inherit; }
.person:hover { border-color: var(--brand); }
</style>
