<script setup>
import { ref, computed, onMounted } from 'vue'
import { api } from '../api/client'
import { label } from '../format'

const sources = ref([])
const category = ref('')
const loading = ref(true)
const error = ref(null)

const categories = computed(() => [...new Set(sources.value.map((s) => s.category))])
const visible = computed(() => (category.value ? sources.value.filter((s) => s.category === category.value) : sources.value))
const tosClass = { allowed: 'good', prohibited: 'bad', unknown: 'neutral' }

onMounted(async () => {
  try {
    sources.value = (await api.get('/data_sources')).data
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <h1>Data Sources</h1>
  <p class="muted">Where Film Mint will pull data from. "Prohibited" means the site's terms forbid scraping, so use its API or official datasets instead.</p>
  <p v-if="loading">Loading…</p>
  <p v-else-if="error" class="error">Could not load sources: {{ error }}</p>
  <div v-else class="card">
    <select v-model="category">
      <option value="">All categories</option>
      <option v-for="c in categories" :key="c" :value="c">{{ label(c) }}</option>
    </select>
    <table>
      <thead><tr><th>Source</th><th>Category</th><th>Access</th><th>Terms</th><th>Data</th></tr></thead>
      <tbody>
        <tr v-for="s in visible" :key="s.id">
          <td><strong>{{ s.name }}</strong></td>
          <td>{{ label(s.category) }}</td>
          <td>{{ s.access_method }}</td>
          <td><span :class="['badge', tosClass[s.tos_status]]">{{ s.tos_status }}</span></td>
          <td class="muted">{{ s.data_to_scrape }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
