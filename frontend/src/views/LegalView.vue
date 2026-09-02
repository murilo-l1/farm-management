<template>
  <div class="legal-page">
    <main class="legal-main">
      <article class="legal-card">
        <header class="legal-header">
          <RouterLink to="/login" class="back-link">
            <span class="material-symbols-outlined">arrow_back</span>
            <span>Voltar</span>
          </RouterLink>

          <div class="brand">
            <div class="brand-icon">
              <Sprout :size="28" color="#fff" :stroke-width="1.5" />
            </div>
            <span class="brand-name">QuantaPlanta</span>
          </div>
        </header>

        <h1 class="legal-title">{{ content.title }}</h1>
        <p class="legal-updated">Última atualização: {{ LAST_UPDATED }}</p>

        <p class="legal-notice">
          Esta é uma versão preliminar, publicada durante a fase de MVP do produto. O texto pode ser
          revisado e atualizado; mudanças relevantes serão comunicadas na tela de acesso.
        </p>

        <section v-for="section in content.sections" :key="section.heading" class="legal-section">
          <h2>{{ section.heading }}</h2>
          <p v-for="(paragraph, i) in section.paragraphs" :key="i">{{ paragraph }}</p>
          <ul v-if="section.items">
            <li v-for="item in section.items" :key="item">{{ item }}</li>
          </ul>
        </section>

        <footer class="legal-footer">
          <RouterLink :to="otherDoc.to">{{ otherDoc.label }}</RouterLink>
          <RouterLink to="/login">Voltar para o acesso</RouterLink>
        </footer>
      </article>
    </main>

    <div class="gradient-bar" />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { Sprout } from 'lucide-vue-next'

type Doc = 'privacy' | 'terms'

interface Section {
  heading: string
  paragraphs: string[]
  items?: string[]
}

interface LegalContent {
  title: string
  sections: Section[]
}

const props = defineProps<{ doc: Doc }>()

const LAST_UPDATED = '01/09/2026'
const CONTACT_EMAIL = 'contato@quantaplanta.com.br'

const PRIVACY: LegalContent = {
  title: 'Política de Privacidade',
  sections: [
    {
      heading: '1. Quem somos',
      paragraphs: [
        'O QuantaPlanta é uma plataforma de gestão agrícola que permite ao produtor registrar ciclos de cultivo, inventário, parceiros comerciais e lançamentos financeiros da sua propriedade.',
        `Para qualquer assunto relacionado ao tratamento dos seus dados pessoais, entre em contato pelo e-mail ${CONTACT_EMAIL}.`,
      ],
    },
    {
      heading: '2. Dados que coletamos',
      paragraphs: [
        'Coletamos apenas o necessário para criar e manter a sua conta e para operar as funcionalidades do sistema:',
      ],
      items: [
        'Dados de cadastro: nome completo, e-mail e telefone.',
        'Senha: armazenada sempre de forma criptografada (hash). Nunca temos acesso à sua senha em texto legível.',
        'Dados operacionais lançados por você: safras, culturas, áreas plantadas, itens de inventário, parceiros (incluindo CPF/CNPJ quando informado) e transações financeiras.',
        'Dados técnicos mínimos de sessão, necessários para manter você autenticado.',
      ],
    },
    {
      heading: '3. Para que usamos os seus dados',
      paragraphs: [
        'Os dados são usados exclusivamente para autenticar o seu acesso, exibir e processar as informações que você mesmo cadastrou, e gerar os indicadores e relatórios da plataforma.',
        'Não usamos os seus dados para publicidade e não realizamos decisões automatizadas com efeitos jurídicos sobre você.',
      ],
    },
    {
      heading: '4. Base legal',
      paragraphs: [
        'O tratamento dos dados de cadastro e dos dados operacionais tem como base legal a execução do contrato firmado com você ao criar a conta, nos termos do art. 7º, V, da Lei nº 13.709/2018 (LGPD).',
        'Quando houver tratamento fora dessa finalidade, ele será feito mediante o seu consentimento específico e destacado.',
      ],
    },
    {
      heading: '5. Compartilhamento',
      paragraphs: [
        'Não vendemos, alugamos nem compartilhamos os seus dados pessoais com terceiros para fins comerciais.',
        'O compartilhamento ocorre apenas com os provedores de infraestrutura necessários para hospedar a aplicação e o banco de dados, e somente na medida necessária para essa finalidade, ou por determinação legal ou judicial.',
      ],
    },
    {
      heading: '6. Retenção e exclusão',
      paragraphs: [
        'Os seus dados são mantidos enquanto a sua conta estiver ativa. Ao solicitar a exclusão da conta, os dados pessoais são removidos, ressalvadas as hipóteses de guarda obrigatória previstas em lei.',
      ],
    },
    {
      heading: '7. Segurança',
      paragraphs: [
        'Adotamos medidas técnicas para proteger os seus dados, incluindo tráfego criptografado, senhas armazenadas com hash e autenticação por token de sessão em cookie protegido, inacessível a scripts do navegador.',
        'Nenhum sistema é totalmente imune a incidentes. Caso ocorra um incidente de segurança relevante, você e a Autoridade Nacional de Proteção de Dados serão comunicados conforme exige a LGPD.',
      ],
    },
    {
      heading: '8. Seus direitos',
      paragraphs: ['Como titular dos dados, a LGPD garante a você o direito de:'],
      items: [
        'Confirmar a existência de tratamento e acessar os seus dados.',
        'Corrigir dados incompletos, inexatos ou desatualizados.',
        'Solicitar a anonimização, o bloqueio ou a eliminação de dados desnecessários ou excessivos.',
        'Solicitar a portabilidade dos seus dados.',
        'Revogar o consentimento e solicitar a exclusão da conta.',
        'Obter informação sobre com quem os seus dados foram compartilhados.',
      ],
    },
    {
      heading: '9. Como exercer os seus direitos',
      paragraphs: [
        `Basta enviar a solicitação para ${CONTACT_EMAIL}. Responderemos no menor prazo possível, observados os prazos previstos na legislação aplicável.`,
      ],
    },
  ],
}

const TERMS: LegalContent = {
  title: 'Termos de Uso',
  sections: [
    {
      heading: '1. Objeto',
      paragraphs: [
        'Estes Termos regulam o uso da plataforma QuantaPlanta, que oferece ferramentas de gestão de ciclos de cultivo, inventário, parceiros comerciais e controle financeiro da propriedade rural.',
        'Ao criar uma conta e utilizar a plataforma, você declara que leu e concorda com estes Termos e com a Política de Privacidade.',
      ],
    },
    {
      heading: '2. Conta de acesso',
      paragraphs: [
        'A conta é pessoal e intransferível. Você é responsável por manter a confidencialidade da sua senha e por todas as atividades realizadas com as suas credenciais.',
        'Caso identifique uso não autorizado da sua conta, altere a senha imediatamente e nos comunique.',
      ],
    },
    {
      heading: '3. Uso aceitável',
      paragraphs: ['Ao utilizar a plataforma, você se compromete a não:'],
      items: [
        'Cadastrar informações falsas ou dados pessoais de terceiros sem autorização.',
        'Tentar acessar contas, dados ou áreas do sistema que não sejam suas.',
        'Realizar engenharia reversa, sobrecarregar o serviço ou interferir no seu funcionamento.',
        'Utilizar a plataforma para qualquer finalidade ilícita.',
      ],
    },
    {
      heading: '4. Conteúdo do usuário',
      paragraphs: [
        'Os dados de safras, inventário, parceiros e transações lançados na plataforma são seus. Não reivindicamos propriedade sobre eles e os utilizamos apenas para prestar o serviço.',
        'Você é o responsável pela veracidade e pela legalidade das informações que cadastra, inclusive por dados de terceiros informados no cadastro de parceiros.',
      ],
    },
    {
      heading: '5. Disponibilidade e limitação de responsabilidade',
      paragraphs: [
        'A plataforma encontra-se em fase de MVP e é fornecida no estado em que se encontra. Podem ocorrer interrupções para manutenção, correções e evolução das funcionalidades.',
        'Os indicadores, relatórios e projeções são ferramentas de apoio à gestão e não substituem a análise técnica, contábil ou agronômica. As decisões tomadas com base neles são de responsabilidade do usuário.',
        'Recomendamos manter cópias próprias das informações críticas do seu negócio.',
      ],
    },
    {
      heading: '6. Encerramento',
      paragraphs: [
        'Você pode encerrar a sua conta a qualquer momento. Podemos suspender ou encerrar contas que violem estes Termos, mediante comunicação sempre que possível.',
      ],
    },
    {
      heading: '7. Alterações',
      paragraphs: [
        'Estes Termos podem ser atualizados para refletir mudanças no serviço ou na legislação. Alterações relevantes serão comunicadas na tela de acesso, e o uso continuado da plataforma após a comunicação significa concordância com a nova versão.',
      ],
    },
    {
      heading: '8. Foro e legislação aplicável',
      paragraphs: [
        `Estes Termos são regidos pela legislação brasileira. Dúvidas sobre o serviço podem ser encaminhadas para ${CONTACT_EMAIL}.`,
      ],
    },
  ],
}

const content = computed<LegalContent>(() => (props.doc === 'privacy' ? PRIVACY : TERMS))

const otherDoc = computed(() =>
  props.doc === 'privacy'
    ? { to: '/termos', label: 'Termos de Uso' }
    : { to: '/privacidade', label: 'Política de Privacidade' },
)
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

.legal-page {
  --primary:                   #0d631b;
  --primary-container:         #2e7d32;
  --surface-container-lowest:  #ffffff;
  --secondary-container:       #fdcdbc;
  --on-surface:                #1a1c1c;
  --on-surface-variant:        #40493d;
  --outline-variant:           #bfcaba;

  height: 100vh;
  overflow-y: auto;
  background-color: #0a0f0a;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem 1.5rem 3.5rem;
  font-family: 'Inter', sans-serif;
}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined', serif;
  font-size: 1.125rem;
}

.legal-main {
  width: 100%;
  max-width: 46rem;
  flex-shrink: 0;
}

.legal-card {
  background-color: var(--surface-container-lowest);
  border-radius: 1.5rem;
  padding: 2.5rem;
  box-shadow: 0 25px 50px -12px color-mix(in srgb, var(--primary) 5%, transparent);
}

/* ── Header ─────────────────────────── */
.legal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--outline-variant);
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--primary);
  text-decoration: none;
}

.back-link:hover { color: var(--primary-container); }

.brand {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.brand-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 0.875rem;
  background: linear-gradient(135deg, var(--primary), var(--primary-container));
  box-shadow: 0 8px 24px color-mix(in srgb, var(--primary) 20%, transparent);
}

.brand-name {
  font-family: 'Manrope', sans-serif;
  font-size: 1.125rem;
  font-weight: 800;
  color: var(--on-surface);
}

/* ── Conteúdo ───────────────────────── */
.legal-title {
  font-family: 'Manrope', sans-serif;
  font-size: 1.75rem;
  font-weight: 800;
  color: var(--on-surface);
  margin: 1.75rem 0 0.375rem;
}

.legal-updated {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-weight: 600;
  color: var(--on-surface-variant);
  opacity: 0.7;
}

.legal-notice {
  margin-top: 1.25rem;
  padding: 0.875rem 1rem;
  border-left: 3px solid var(--secondary-container);
  background: color-mix(in srgb, var(--secondary-container) 20%, transparent);
  border-radius: 0 0.5rem 0.5rem 0;
  font-size: 0.8125rem;
  line-height: 1.6;
  color: var(--on-surface-variant);
}

.legal-section { margin-top: 1.75rem; }

.legal-section h2 {
  font-family: 'Manrope', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  color: var(--on-surface);
  margin-bottom: 0.5rem;
}

.legal-section p {
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--on-surface-variant);
  margin-bottom: 0.625rem;
}

.legal-section ul {
  margin: 0.25rem 0 0.625rem 1.125rem;
  padding: 0;
}

.legal-section li {
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--on-surface-variant);
  margin-bottom: 0.375rem;
}

/* ── Footer ─────────────────────────── */
.legal-footer {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin-top: 2.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--outline-variant);
}

.legal-footer a {
  font-size: 0.625rem;
  font-weight: 700;
  color: var(--primary);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  text-decoration: none;
}

.legal-footer a:hover { color: var(--primary-container); }

/* ── Gradient bar ───────────────────── */
.gradient-bar {
  position: fixed; bottom: 0; left: 0;
  width: 100%; height: 6px;
  background: linear-gradient(to right, var(--primary), var(--primary-container), var(--secondary-container));
  z-index: 10;
}

@media (max-width: 40rem) {
  .legal-card { padding: 1.5rem; }
  .legal-title { font-size: 1.375rem; }
}
</style>
