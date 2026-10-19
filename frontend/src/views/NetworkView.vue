<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { api } from '../api/client'
import ThreadPath from '../components/ThreadPath.vue'
import { label, kindColor, KIND_LEGEND, industryName } from '../format'

const route = useRoute()
const network = ref(null)
const target = ref(null) // { id, name, kind, source }
const result = ref(null)
const search = ref('')
const matches = ref([])
const strength = ref(3)
const error = ref(null)
const notice = ref(null)
const busy = ref(false)
let timer

const strengthWord = ['', 'acquaintance', 'know each other', 'good contact', 'close', 'very close']

async function loadNetwork() {
  network.value = (await api.get('/connections/network')).data
}

async function findPath() {
  result.value = null
  if (!target.value) return
  try {
    result.value = (await api.get('/connections/path', { params: { to: target.value.id } })).data
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  }
}

function choose(p) {
  target.value = p
  search.value = ''
  matches.value = []
  notice.value = null
}

async function knowThem() {
  busy.value = true
  error.value = null
  try {
    await api.post('/connections', { person_id: network.value.me, other_person_id: target.value.id, strength: strength.value })
    notice.value = `Added ${target.value.name} to your network.`
    await loadNetwork()
    await findPath()
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  } finally {
    busy.value = false
  }
}

watch(search, (q) => {
  clearTimeout(timer)
  if (!q.trim()) { matches.value = []; return }
  timer = setTimeout(async () => {
    matches.value = (await api.get('/people', { params: { q } })).data.slice(0, 8)
  }, 200)
})
watch(target, findPath)

onMounted(async () => {
  try {
    await loadNetwork()
    if (route.query.to) choose((await api.get(`/people/${route.query.to}`)).data)
  } catch (e) {
    error.value = e.response?.data?.error || e.message
  }
})

const node = (id) => network.value.nodes.find((n) => n.id === id)
</script>

<template>
  <h1>My Network</h1>
  <p class="muted">
    Search anyone, real or demo. Film Mint finds the shortest chain of introductions, using the people you know and
    people who worked together on the same film (from real film credits).
  </p>
  <p v-if="error" class="error">{{ error }}</p>
  <p v-else-if="!network">Loading…</p>
  <template v-else>
    <label for="q">I want to reach</label>
    <input id="q" v-model="search" placeholder="Search a name, e.g. Aamir, Marcus, Léa…" style="width: min(420px, 100%)" autocomplete="off" />
    <ul v-if="matches.length" class="matches">
      <li v-for="m in matches" :key="m.id" @click="choose(m)">
        <span class="dot" :style="{ background: kindColor(m.kind) }" />
        <span>{{ m.name }} <span class="muted">· {{ label(m.kind) }} · {{ industryName(m.industry) }}</span></span>
        <span :class="['badge', m.source === 'wikidata' ? 'good' : 'neutral']">{{ m.source === 'wikidata' ? 'Real' : 'Demo' }}</span>
      </li>
    </ul>
    <p class="legend">
      <span v-for="k in KIND_LEGEND" :key="k" class="chip" :style="{ borderColor: kindColor(k) }">{{ label(k) }}</span>
    </p>

    <p v-if="notice" class="notice">{{ notice }}</p>

    <section v-if="target && result" class="card">
      <h2>To {{ target.name }}</h2>
      <template v-if="result.path.length">
        <p class="muted">{{ result.degrees }} {{ result.degrees === 1 ? 'degree' : 'degrees' }} of separation</p>
        <ThreadPath :path="result.path" :steps="result.steps" />
        <div class="flow">
          <template v-for="(p, i) in result.path" :key="p.id">
            <div class="step" :style="{ borderColor: kindColor(p.kind) }">
              <strong>{{ p.name }}</strong>
              <span class="muted small">{{ i === 0 ? 'You' : label(p.kind) }}</span>
            </div>
            <div v-if="i < result.path.length - 1" class="link"
              :style="{ '--from': kindColor(p.kind), '--to': kindColor(result.path[i + 1].kind) }">
              <span class="line" />
              <span class="small muted">{{ result.notes[i] || strengthWord[result.steps[i]] || 'connected' }}</span>
            </div>
          </template>
        </div>
        <p v-if="result.path.length > 1" class="muted">Ask {{ result.path[1].name }} first: they are your way in.</p>
      </template>
      <template v-else>
        <p>{{ result.message }}</p>
      </template>

      <div v-if="result.degrees !== 1" class="know">
        <strong>Do you know {{ target.name }}?</strong>
        <select v-model.number="strength">
          <option v-for="n in 5" :key="n" :value="n">{{ strengthWord[n] }}</option>
        </select>
        <button class="btn" :disabled="busy" @click="knowThem">I know them</button>
      </div>
    </section>

    <section class="card" style="margin-top: 16px">
      <h2>People you know</h2>
      <p class="muted small">{{ network.edges.length }} saved connections. Anyone you add here becomes your starting point into the film credits graph.</p>
      <table>
        <thead><tr><th>Person</th><th>Knows</th><th>How</th></tr></thead>
        <tbody>
          <tr v-for="e in network.edges" :key="e.from + '-' + e.to">
            <td><span class="chip" :style="{ borderColor: kindColor(node(e.from).kind) }">{{ node(e.from).name }}</span></td>
            <td><span class="chip" :style="{ borderColor: kindColor(node(e.to).kind) }">{{ node(e.to).name }}</span></td>
            <td class="muted">{{ e.note || strengthWord[e.strength] }}</td>
          </tr>
        </tbody>
      </table>
    </section>
  </template>
</template>

<style scoped>
.matches { list-style: none; margin: 4px 0 0; padding: 0; width: min(420px, 100%); background: var(--panel); border: 1px solid var(--line); border-radius: 8px; }
.matches li { display: flex; align-items: center; gap: 10px; padding: 8px 12px; cursor: pointer; border-bottom: 1px solid var(--line); }
.matches li:last-child { border: 0; }
.matches li:hover { background: var(--neutral-bg); }
.matches li .badge { margin-left: auto; }
.dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.legend { display: flex; flex-wrap: wrap; gap: 8px; }
.chip { display: inline-block; border: 2px solid; border-radius: 14px; padding: 1px 10px; font-size: .85rem; background: rgba(255,255,255,.04); }
.flow { display: flex; align-items: stretch; flex-wrap: wrap; gap: 0; margin: 12px 0; }
.step { border: 2px solid; border-radius: 10px; padding: 10px 14px; display: flex; flex-direction: column; background: rgba(255,255,255,.04); min-width: 130px; }
.link { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 0 8px; min-width: 110px; max-width: 190px; text-align: center; }
.line { height: 3px; width: 100%; border-radius: 2px; background: linear-gradient(90deg, var(--from), var(--to)); }
.small { font-size: .8rem; }
.know { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-top: 14px; padding-top: 14px; border-top: 1px solid var(--line); }
.notice { border: 1px solid var(--ok); background: rgba(74, 222, 128, 0.1); border-radius: 8px; padding: 8px 12px; }
</style>
