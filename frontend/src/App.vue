<script setup>
import AppIcon from './components/AppIcon.vue'

const links = [
  { to: '/', label: 'Home', icon: 'home', color: '#7dd3fc', exact: true },
  { to: '/projects', label: 'Projects', icon: 'folder', color: '#fbbf24' },
  { to: '/people', label: 'People', icon: 'users', color: '#f472b6' },
  { to: '/films', label: 'Films', icon: 'film', color: '#fb923c' },
  { to: '/network', label: 'My Network', icon: 'network', color: '#a78bfa' },
  { to: '/sources', label: 'Data Sources', icon: 'database', color: '#34d399' },
]
const soon = [
  { label: 'Teams', icon: 'users', color: '#fb923c' }, { label: 'News', icon: 'news', color: '#60a5fa' },
  { label: 'Scripts', icon: 'script', color: '#c084fc' }, { label: 'Financing', icon: 'money', color: '#4ade80' },
  { label: 'Analytics', icon: 'chart', color: '#f87171' },
]
</script>

<template>
  <aside class="sidebar">
    <RouterLink to="/" class="brand">
      <span class="mark">FM</span>
      <span><span class="name">Film Mint</span><span class="sub">Greenlight</span></span>
    </RouterLink>
    <nav>
      <RouterLink v-for="n in links" :key="n.to" :to="n.to" :exact-active-class="n.exact ? 'active' : ''"
        :active-class="n.exact ? '' : 'active'">
        <AppIcon :name="n.icon" :color="n.color" />{{ n.label }}
      </RouterLink>
      <div class="section">Coming soon</div>
      <span v-for="s in soon" :key="s.label" class="soon">
        <span class="soon-label"><AppIcon :name="s.icon" :color="s.color" />{{ s.label }}</span><em>Soon</em>
      </span>
    </nav>
    <span class="demo" title="All people, films and numbers are fictional sample data">Demo data</span>
  </aside>
  <main><RouterView /></main>
</template>

<style scoped>
.sidebar { position: fixed; top: 0; left: 0; bottom: 0; width: var(--sidebar-w); background: #2b2b30;
  border-right: 1px solid var(--line); padding: 24px 16px 18px; display: flex; flex-direction: column; gap: 18px; z-index: 10; }
.brand { display: flex; align-items: center; gap: 10px; text-decoration: none; padding: 0 6px 18px; border-bottom: 1px solid var(--line); }
.mark { width: 34px; height: 34px; border-radius: 8px; background: #fff; color: #000; display: flex; align-items: center;
  justify-content: center; font-weight: 800; font-size: .8rem; font-family: var(--font-display); }
.name { display: block; font-family: var(--font-display); font-weight: 700; color: #fff; line-height: 1.2; }
.sub { display: block; font-size: .65rem; letter-spacing: .14em; text-transform: uppercase; color: var(--muted); }
nav { display: flex; flex-direction: column; gap: 3px; flex: 1; overflow-y: auto; }
nav a { color: var(--muted); text-decoration: none; padding: 9px 12px; border-radius: 8px; display: flex; align-items: center; gap: 10px; }
nav a:hover { color: #fff; background: var(--neutral-bg); }
nav a.active { color: #000; background: #fff; font-weight: 600; }
.section { font-size: .65rem; letter-spacing: .14em; text-transform: uppercase; color: var(--muted); margin: 18px 12px 6px; }
.soon { display: flex; justify-content: space-between; align-items: center; padding: 7px 12px; color: rgba(255,255,255,.45); }
.soon-label { display: flex; align-items: center; gap: 10px; }
.soon-label svg { opacity: .6; }
.soon em { font-style: normal; font-size: .65rem; letter-spacing: .08em; text-transform: uppercase; }
.demo { align-self: flex-start; border: 1px solid rgba(255,255,255,.4); color: #fff; padding: 2px 10px; border-radius: 12px; font-size: .8rem; font-weight: 600; }
main { margin-left: var(--sidebar-w); padding: 28px 32px; max-width: calc(1200px + var(--sidebar-w)); }
@media (max-width: 800px) {
  .sidebar { position: static; width: auto; flex-direction: row; flex-wrap: wrap; align-items: center; padding: 12px 16px; }
  .brand { border: 0; padding: 0; }
  nav { flex-direction: row; flex-wrap: wrap; flex: 1; }
  .section, .soon { display: none; }
  main { margin-left: 0; padding: 20px 16px; }
}
</style>
