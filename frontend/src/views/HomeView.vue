<script setup>
import { ref, onMounted } from 'vue'
import { api } from '../api/client'
import { money, label, riskClass, capitalize } from '../format'
import AppIcon from '../components/AppIcon.vue'

const data = ref(null)
const error = ref(null)

const stages = [
  ['development', 'Development'], ['financing', 'Financing'], ['pre_production', 'Pre-Production'],
  ['production', 'Production'], ['post', 'Post / Released'],
]

onMounted(async () => {
  try {
    data.value = (await api.get('/dashboard')).data
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  }
})
</script>

<template>
  <h1>Welcome back.</h1>
  <p class="muted">Your greenlight pipeline at a glance. Open a project to build its package and check value and risk.</p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-else-if="!data">Loading…</p>
  <template v-else>
    <div class="grid metrics">
      <div class="card metric"><AppIcon name="film" color="#fbbf24" :size="26" /><div><div class="num">{{ data.metrics.active_projects }}</div><div class="muted">Active projects</div></div></div>
      <div class="card metric"><AppIcon name="users" color="#f472b6" :size="26" /><div><div class="num">{{ data.metrics.people_packaged }}</div><div class="muted">People in packages</div></div></div>
      <div class="card metric"><AppIcon name="alert" color="#f87171" :size="26" /><div><div class="num">{{ data.metrics.high_risk_projects }}</div><div class="muted">High-risk projects</div></div></div>
    </div>

    <h2 style="margin-top: 28px">Greenlight pipeline</h2>
    <div class="grid pipeline">
      <section v-for="[key, title] in stages" :key="key" class="card col">
        <h3>{{ title }} <span class="muted">{{ data.pipeline[key].length }}</span></h3>
        <p v-if="!data.pipeline[key].length" class="muted small">Nothing here yet.</p>
        <RouterLink v-for="p in data.pipeline[key]" :key="p.id" :to="{ name: 'project', params: { id: p.id } }" class="proj">
          <strong>{{ p.title }}</strong>
          <span class="muted small">{{ capitalize(p.genre) || 'No genre' }} · {{ money(p.budget_usd) }} · {{ p.member_count }} in package</span>
          <span v-if="p.risk_level" :class="['badge', riskClass(p.risk_level)]">{{ p.risk_level }} risk</span>
        </RouterLink>
      </section>
    </div>

    <h2 style="margin-top: 28px">Recently updated</h2>
    <div class="card">
      <table>
        <tbody>
          <tr v-for="p in data.recent" :key="p.id">
            <td><RouterLink :to="{ name: 'project', params: { id: p.id } }">{{ p.title }}</RouterLink></td>
            <td class="muted">{{ label(p.status) }}</td>
            <td class="muted">{{ new Date(p.updated_at).toLocaleDateString() }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
</template>

<style scoped>
.metric { display: flex; align-items: center; gap: 16px; }
.metrics { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); margin-top: 18px; }
.num { font-family: var(--font-display); font-size: 2rem; font-weight: 700; line-height: 1.1; }
.pipeline { grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); align-items: start; }
.col h3 { display: flex; justify-content: space-between; }
.proj { display: flex; flex-direction: column; gap: 4px; padding: 10px; margin-top: 8px; border: 1px solid var(--line);
  border-radius: 8px; text-decoration: none; align-items: flex-start; }
.proj:hover { border-color: #fff; }
.small { font-size: .85rem; }
</style>
