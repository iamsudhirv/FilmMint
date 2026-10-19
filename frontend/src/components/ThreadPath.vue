<script setup>
import { computed } from 'vue'
import { kindColor } from '../format'

const props = defineProps({ path: { type: Array, required: true }, steps: { type: Array, default: () => [] } })

const W = 900, H = 230, PAD = 110
const nodes = computed(() => {
  const n = props.path.length
  return props.path.map((p, i) => ({
    ...p,
    color: kindColor(p.kind),
    x: n === 1 ? W / 2 : PAD + (i * (W - 2 * PAD)) / (n - 1),
    y: H / 2 + (i % 2 === 0 ? -28 : 28),
    initials: p.name.replace(/\(.*\)/, '').trim().split(' ').map((w) => w[0]).slice(0, 2).join(''),
  }))
})

// Smooth "thread" between nodes, fading from one person's colour to the next.
const threads = computed(() =>
  nodes.value.slice(0, -1).map((a, i) => {
    const b = nodes.value[i + 1]
    const mx = (a.x + b.x) / 2
    return { a, b, d: `M ${a.x} ${a.y} C ${mx} ${a.y - 55}, ${mx} ${b.y + 55}, ${b.x} ${b.y}`, strength: props.steps[i] || 3 }
  }),
)
</script>

<template>
  <svg :viewBox="`0 0 ${W} ${H}`" role="img" aria-label="Introduction path" class="thread">
    <defs>
      <linearGradient v-for="(t, i) in threads" :id="'g' + i" :key="'d' + i" gradientUnits="userSpaceOnUse"
        :x1="t.a.x" :y1="t.a.y" :x2="t.b.x" :y2="t.b.y">
        <stop offset="0" :stop-color="t.a.color" /><stop offset="1" :stop-color="t.b.color" />
      </linearGradient>
    </defs>
    <path v-for="(t, i) in threads" :key="'t' + i" :d="t.d" fill="none" :stroke="`url(#g${i})`"
      :stroke-width="1.5 + t.strength" stroke-linecap="round" opacity=".95" />
    <g v-for="n in nodes" :key="n.id">
      <circle :cx="n.x" :cy="n.y" r="26" fill="#46464d" :stroke="n.color" stroke-width="3.5" />
      <text :x="n.x" :y="n.y + 5" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">{{ n.initials }}</text>
      <text :x="n.x" :y="n.y + (n.y < H / 2 ? -38 : 50)" text-anchor="middle" font-size="15" fill="#ffffff">{{ n.name }}</text>
    </g>
  </svg>
</template>

<style scoped>
.thread { width: 100%; height: auto; max-height: 280px; }
</style>
