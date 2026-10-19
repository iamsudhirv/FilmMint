<script setup>
import { ref, watch, onMounted } from 'vue'
import { api } from '../api/client'
import { money, label, capitalize, industryName } from '../format'

const films = ref([])
const industries = ref([])
const industry = ref('')
const source = ref('')
const loading = ref(true)
const error = ref(null)

async function load() {
  loading.value = true
  try {
    films.value = (await api.get('/films', { params: { industry: industry.value, source: source.value } })).data
    error.value = null
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

watch([industry, source], load)
onMounted(async () => {
  industries.value = (await api.get('/industries')).data
  load()
})
</script>

<template>
  <h1>Films</h1>
  <p class="muted">
    <span class="badge good">Real</span> rows come from Wikidata (worldwide totals only, no territory split).
    <span class="badge neutral">Demo</span> rows are fictional and carry a territory-by-territory split.
  </p>
  <p>
    <select v-model="industry">
      <option value="">All industries</option>
      <option v-for="i in industries" :key="i.key" :value="i.key">{{ i.label }}</option>
    </select>
    <select v-model="source" style="margin-left: 10px">
      <option value="">Real and demo</option>
      <option value="wikidata">Real only</option>
      <option value="demo">Demo only</option>
    </select>
    <span class="muted" style="margin-left: 12px">{{ films.length }} films</span>
  </p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-else-if="loading">Loading…</p>
  <div v-else class="card" style="padding: 0; overflow-x: auto">
    <table>
      <thead><tr><th>Film</th><th>Year</th><th>Industry</th><th>Language</th><th>Genre</th><th>Budget</th><th>Worldwide gross</th><th>Source</th></tr></thead>
      <tbody>
        <tr v-for="f in films" :key="f.id">
          <td><strong>{{ f.title }}</strong></td>
          <td>{{ f.year }}</td>
          <td>{{ industryName(f.industry) }}</td>
          <td>{{ f.language || '—' }}</td>
          <td>{{ capitalize(f.genre) || '—' }}</td>
          <td>{{ money(f.budget_usd) }}</td>
          <td>{{ money(f.worldwide_gross_usd) }}</td>
          <td>
            <a v-if="f.wikidata_url" :href="f.wikidata_url" target="_blank" rel="noopener"><span class="badge good">Real · Wikidata</span></a>
            <span v-else class="badge neutral">Demo</span>
          </td>
        </tr>
        <tr v-if="!films.length"><td colspan="8" class="muted">No films match.</td></tr>
      </tbody>
    </table>
  </div>
</template>
