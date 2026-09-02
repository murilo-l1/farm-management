import type { ToastServiceMethods } from 'primevue/toastservice'

let instance: ToastServiceMethods | null = null

export function registerToast(toast: ToastServiceMethods) {
  instance = toast
}

type Severity = 'success' | 'info' | 'warn' | 'error'

// Títulos exibidos no toast — única fonte, usada tanto pelos helpers públicos
// quanto pelo tratamento de erro do interceptor.
const SUMMARY: Record<Severity, string> = {
  success: 'Sucesso',
  info: 'Informação',
  warn: 'Atenção',
  error: 'Erro',
}

function severityFromStatus(status: number): Severity {
  if (status >= 500) return 'error'
  if (status === 403) return 'error'
  return 'warn'
}

export const toast = {
  success(detail: string, summary = SUMMARY.success) {
    instance?.add({ severity: 'success', summary, detail, life: 3000 })
  },
  warn(detail: string, summary = SUMMARY.warn) {
    instance?.add({ severity: 'warn', summary, detail, life: 4000 })
  },
  error(detail: string, summary = SUMMARY.error) {
    instance?.add({ severity: 'error', summary, detail, life: 5000 })
  },
  fromApiError(error: unknown) {
    const response = (error as any)?.response
    if (!response) {
      instance?.add({ severity: 'error', summary: SUMMARY.error, detail: 'Não foi possível conectar ao servidor.', life: 5000 })
      return
    }
    const message: string = response.data?.message ?? 'Erro inesperado.'
    const severity = severityFromStatus(response.status)
    // Validações retornam múltiplas mensagens separadas por "; "
    const messages = message.split('; ')
    messages.forEach((detail) =>
      instance?.add({ severity, summary: SUMMARY[severity], detail, life: 4500 }),
    )
  },
}
