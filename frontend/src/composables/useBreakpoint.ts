import { ref, readonly, type Ref } from 'vue'

const MOBILE_QUERY = '(max-width: 767px)'
const DESKTOP_NAV_QUERY = '(min-width: 1024px)'

function mediaRef(query: string): Ref<boolean> {
  const mql = window.matchMedia(query)
  const matches = ref(mql.matches)
  mql.addEventListener('change', (e) => (matches.value = e.matches))
  return matches
}

// criados uma vez só, o app inteiro usa os mesmos listeners
const isMobile = mediaRef(MOBILE_QUERY)
const isDesktopNav = mediaRef(DESKTOP_NAV_QUERY)

export function useBreakpoint() {
  return {
    isMobile: readonly(isMobile),
    isDesktopNav: readonly(isDesktopNav),
  }
}
