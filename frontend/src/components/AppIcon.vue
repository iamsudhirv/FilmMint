<script setup>
// Small inline icon set (24x24, stroke style). Colour is passed in so each icon can be colourful.
defineProps({ name: { type: String, required: true }, color: { type: String, default: 'currentColor' }, size: { type: Number, default: 18 } })

const icons = {
  home: '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
  folder: '<path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
  users: '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c0-3.3 2.9-6 6.5-6s6.5 2.7 6.5 6"/><circle cx="17" cy="9" r="2.5"/><path d="M17 14c2.8 0 4.5 2 4.5 4.5"/>',
  network: '<circle cx="6" cy="6" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="12" cy="18" r="2.5"/><path d="M8.5 6h7M7.3 8l3.4 8M16.7 8l-3.4 8"/>',
  database: '<ellipse cx="12" cy="6" rx="8" ry="3"/><path d="M4 6v6c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/>',
  news: '<path d="M4 4h13a2 2 0 0 1 2 2v14H6a2 2 0 0 1-2-2zM8 9h7M8 13h7M8 17h4"/>',
  script: '<path d="M6 3h9l4 4v14H6zM14 3v5h5M9 13h6M9 17h6"/>',
  money: '<circle cx="12" cy="12" r="9"/><path d="M12 7v10M15 9.5c0-1-1.3-1.7-3-1.7s-3 .8-3 2 1.3 1.7 3 2 3 .9 3 2-1.3 2-3 2-3-.8-3-1.8"/>',
  chart: '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
  film: '<rect x="3" y="7" width="18" height="13" rx="1"/><path d="m3 7 3-4h4L7 7M10 7l3-4h4l-3 4"/>',
  alert: '<path d="M12 3 2 20h20zM12 10v5M12 18v.01"/>',
}
</script>

<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" :stroke="color" stroke-width="1.8"
    stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="icon" v-html="icons[name]" />
</template>

<style scoped>
.icon { flex-shrink: 0; }
</style>
