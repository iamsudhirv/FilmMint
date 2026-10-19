import { createRouter, createWebHistory } from 'vue-router'
import HomeView from './views/HomeView.vue'
import ProjectsView from './views/ProjectsView.vue'
import ProjectView from './views/ProjectView.vue'
import PeopleView from './views/PeopleView.vue'
import PersonView from './views/PersonView.vue'
import FilmsView from './views/FilmsView.vue'
import NetworkView from './views/NetworkView.vue'
import DataSourcesView from './views/DataSourcesView.vue'

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/projects', name: 'projects', component: ProjectsView },
    { path: '/projects/:id', name: 'project', component: ProjectView, props: true },
    { path: '/people', name: 'people', component: PeopleView },
    { path: '/people/:id', name: 'person', component: PersonView, props: true },
    { path: '/films', name: 'films', component: FilmsView },
    { path: '/network', name: 'network', component: NetworkView },
    { path: '/sources', name: 'sources', component: DataSourcesView },
  ],
})
