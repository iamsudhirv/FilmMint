<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../api/client'
import { money, label, territoryColor, industryName, capitalize } from '../format'

const props = defineProps({ id: String })
const person = ref(null)
const error = ref(null)

const maxGross = computed(() => Math.max(1, ...(person.value?.territory_strengths || []).map((t) => t.attributed_gross_usd)))
const persona = computed(() => ['No concerns', 'Minor concerns', 'Significant concerns', 'Severe concerns'][person.value?.controversy_level ?? 0])

onMounted(async () => {
  try {
    person.value = (await api.get(`/people/${props.id}`)).data
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  }
})
</script>

<template>
  <p><RouterLink to="/people">← People</RouterLink></p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-else-if="!person">Loading…</p>
  <template v-else>
    <h1>{{ person.name }}</h1>
    <p>
      <span class="badge neutral">{{ label(person.kind) }}</span>
      <span class="badge neutral" style="margin-left: 6px">{{ industryName(person.industry) }}</span>
      <span v-if="person.nationality" class="muted"> · {{ person.nationality }}</span>
      <RouterLink :to="{ name: 'network', query: { to: person.id } }" class="btn small secondary" style="margin-left: 12px">How do I reach them?</RouterLink>
    </p>
    <p v-if="person.bio">{{ person.bio }}</p>

    <div class="grid two">
      <section class="card">
        <h2>Where their films have sold</h2>
        <p class="muted">Average box office attributed to this person per film, by territory ({{ person.film_count }} films on file).</p>
        <p v-if="!person.territory_strengths.length" class="muted">No performance data yet.</p>
        <div v-for="t in person.territory_strengths" :key="t.territory" class="bar-row">
          <span class="bar-label"><i class="dot" :style="{ background: territoryColor(t.territory) }" />{{ t.territory }}</span>
          <span class="bar"><span :style="{ width: (t.attributed_gross_usd / maxGross) * 100 + '%', background: territoryColor(t.territory) }" /></span>
          <span class="bar-val">{{ money(t.attributed_gross_usd) }}</span>
        </div>
      </section>

      <section class="card">
        <h2>Value and persona</h2>
        <table>
          <tbody>
            <tr><th>Asking fee</th><td>{{ money(person.fee_usd) }}</td></tr>
            <tr><th>Social following</th><td>{{ person.social_followers ? person.social_followers.toLocaleString() : '—' }}</td></tr>
            <tr><th>Engagement</th><td>{{ person.social_engagement_pct != null ? person.social_engagement_pct + '%' : '—' }}</td></tr>
            <tr><th>Public persona</th><td>{{ persona }}<span v-if="person.persona_notes" class="muted"> — {{ person.persona_notes }}</span></td></tr>
            <tr><th>Public politics</th><td>{{ person.politics_lean || 'unknown' }}</td></tr>
          </tbody>
        </table>
        <p class="muted small">Persona and politics are entered by the team, not scraped, and are only a signal for risk review.</p>
      </section>
    </div>

    <section class="card" style="margin-top: 16px">
      <h2>Credits</h2>
      <table>
        <thead><tr><th>Film</th><th>Year</th><th>Industry</th><th>Language</th><th>Genre</th><th>Role</th><th>Billing</th></tr></thead>
        <tbody>
          <tr v-for="c in person.credits" :key="c.film + c.role">
            <td>{{ c.film }}</td><td>{{ c.year }}</td><td>{{ industryName(c.industry) }}</td><td>{{ c.language }}</td><td>{{ capitalize(c.genre) }}</td><td>{{ c.role }}</td><td>#{{ c.billing_order }}</td>
          </tr>
        </tbody>
      </table>
    </section>
  </template>
</template>

<style scoped>
.two { grid-template-columns: 1fr 1fr; align-items: start; }
.bar-row { display: grid; grid-template-columns: 130px 1fr 70px; gap: 10px; align-items: center; margin: 6px 0; }
.bar { background: var(--neutral-bg); border-radius: 6px; height: 14px; overflow: hidden; }
.bar span { display: block; height: 100%; background: var(--brand); }
.bar-label { display: flex; align-items: center; gap: 8px; }
.dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.bar-val { text-align: right; font-variant-numeric: tabular-nums; }
.small { font-size: .85rem; }
@media (max-width: 800px) { .two { grid-template-columns: 1fr; } }
</style>
