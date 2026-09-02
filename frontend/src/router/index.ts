import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresGuest: true },
    },
    {
      path: '/privacidade',
      name: 'privacidade',
      component: () => import('@/views/LegalView.vue'),
      props: { doc: 'privacy' },
    },
    {
      path: '/termos',
      name: 'termos',
      component: () => import('@/views/LegalView.vue'),
      props: { doc: 'terms' },
    },
    {
      path: '/',
      component: () => import('@/views/AppLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        { path: '',           redirect: '/dashboard' },
        { path: 'dashboard',  name: 'dashboard',  component: () => import('@/views/DashboardView.vue')  },
        { path: 'safras',     name: 'safras',     component: () => import('@/views/CropCycleView.vue')     },
        { path: 'financeiro', name: 'financeiro', component: () => import('@/views/TransactionView.vue') },
        { path: 'inventario', name: 'inventario', component: () => import('@/views/ItemView.vue') },
        { path: 'categorias', name: 'categorias', component: () => import('@/views/CategoryView.vue') },
        { path: 'parceiros',  name: 'parceiros',  component: () => import('@/views/StakeholderView.vue')  },
      ],
    },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  const requiresAuth = to.matched.some((r) => r.meta.requiresAuth)
  const requiresGuest = to.matched.some((r) => r.meta.requiresGuest)
  if (requiresAuth && !auth.isAuthenticated) return '/login'
  if (requiresGuest && auth.isAuthenticated) return '/dashboard'
})

export default router
