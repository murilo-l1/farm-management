import { ref } from 'vue'

// quem fecha o menu ao trocar de página é o router.afterEach
const mobileMenuOpen = ref(false)

export function useLayout() {
  return {
    mobileMenuOpen,
    toggleMenu: () => (mobileMenuOpen.value = !mobileMenuOpen.value),
    closeMenu: () => (mobileMenuOpen.value = false),
  }
}
