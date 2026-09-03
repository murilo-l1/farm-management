# Deploy — Cloud Run + Neon (custo R$ 0,00)

Alternativa à VM. **Um container** com Caddy + Spring Boot, servindo SPA e API
pela mesma origem, e o Postgres na Neon.

```
Internet ──https──▶ Cloud Run (escala a zero)
                      │  1 container:
                      │    Caddy :$PORT ──/api/*──▶ Spring Boot :8081
                      │      └── / ──▶ Vue (SPA)         │
                      └──────────────────────────────────┼── TLS ──▶ Neon Postgres
```

Mesma origem = o cookie JWT (`HttpOnly; Secure; SameSite=None`) funciona sem
alteração de código e sem CORS, igual ao plano da VM.

> **Cold start**: com zero tráfego o container hiberna. O primeiro acesso leva
> ~15-25s (Cloud Run acordando + Spring subindo + Neon saindo do autosuspend).
> Os acessos seguintes são normais. É o preço de não ter servidor ligado.

---

## Parte 1 — Banco na Neon

1. neon.tech → criar conta (não pede cartão) → novo projeto, região
   **AWS us-east-2** ou **us-east-1** (perto do Cloud Run em `us-central1`).
2. Copie a connection string do **Pooled connection** (recomendada para serverless).
   Formato: `postgresql://user:senha@ep-xxx-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require`
3. **Aplique o schema** — a Neon é banco gerenciado, não roda
   `docker-entrypoint-initdb.d`, e o Spring sobe com `ddl-auto=validate`:

```bash
# no seu Windows, com psql instalado (ou pelo SQL Editor do console da Neon)
psql "postgresql://...connection string..." -f docker/init/init.sql
psql "postgresql://...connection string..." -f docker/init/demo_data.sql
```

4. Monte a **URL JDBC** (formato diferente da string da Neon):

```
jdbc:postgresql://ep-xxx-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require
```
Usuário e senha vão separados, nas variáveis `DB_USER` e `DB_PASSWORD`.

---

## Parte 2 — Projeto no Google Cloud

```bash
gcloud auth login
gcloud projects create farm-management-tcc --name="Farm Management TCC"
gcloud config set project farm-management-tcc
```

Ative o faturamento no console (obrigatório mesmo no free tier), depois:

```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com

gcloud artifacts repositories create farm \
    --repository-format=docker --location=us-central1

gcloud auth configure-docker us-central1-docker.pkg.dev
```

> **Região `us-central1` de propósito**: o egress gratuito do Cloud Run é
> "1 GB/mês a partir da América do Norte". São Paulo daria ~100ms a menos de
> latência, mas passaria a cobrar egress. Com um SPA de ~500 KB por primeira
> visita, 1 GB cobre ~2000 visitas novas por mês — de sobra para o TCC.

---

## Parte 3 — Build e deploy

```bash
IMG=us-central1-docker.pkg.dev/farm-management-tcc/farm/app

docker build -f Dockerfile.allinone -t $IMG:v1 .
docker push $IMG:v1

gcloud run deploy farm-management \
    --image=$IMG:v1 \
    --region=us-central1 \
    --allow-unauthenticated \
    --memory=1Gi \
    --cpu=1 \
    --min-instances=0 \
    --max-instances=3 \
    --timeout=300 \
    --set-env-vars="SPRING_PROFILES_ACTIVE=prod,SERVER_PORT=8081,TZ=America/Sao_Paulo" \
    --set-env-vars="SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=5,SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=0,SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT=30000" \
    --set-env-vars="DB_URL=jdbc:postgresql://ep-xxx-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require" \
    --set-env-vars="DB_USER=...,DB_PASSWORD=...,JWT_SECRET=..."
```

O comando devolve a URL (`https://farm-management-xxxx.us-central1.run.app`).
**Falta um passo**: o `CORS_ORIGINS` precisa conter essa URL, que você só
conhece depois do primeiro deploy. Rode uma vez mais:

```bash
gcloud run services update farm-management --region=us-central1 \
    --set-env-vars="CORS_ORIGINS=https://farm-management-xxxx.us-central1.run.app"
```

> `--min-instances=0` é obrigatório para ficar no free tier. Com 1 instância
> sempre ligada seriam ~1,3M GB-s/mês contra 360k gratuitos.

> **`SPRING_DATASOURCE_HIKARI_CONNECTION_TIMEOUT=30000` não é opcional.**
> O `application.properties` traz `connection-timeout=3000` (3s), afinado para um
> Postgres local na mesma máquina. Contra a Neon saindo do autosuspend, 3s estoura
> e a primeira requisição depois de uma hibernação falha com timeout de conexão.
> 30s dá folga para o banco acordar.

**Gere o `JWT_SECRET` com `tr -d '\r\n'`**, não só `tr -d '\n'` — no Windows o
`openssl` termina a linha com CRLF, o `\r` fica no valor e o Spring falha no boot
com `IllegalArgumentException: Illegal base64 character d`.

```bash
openssl rand -base64 64 | tr -d '\r\n'
```

---

## Operação

```bash
# Logs
gcloud run services logs read farm-management --region=us-central1 --limit=50

# Publicar atualização
docker build -f Dockerfile.allinone -t $IMG:v2 . && docker push $IMG:v2
gcloud run deploy farm-management --image=$IMG:v2 --region=us-central1

# Artifact Registry só tem 0.5 GB grátis e a imagem tem ~300 MB:
# apague a versão antiga depois de validar a nova.
gcloud artifacts docker images delete $IMG:v1 --quiet
```

**Backup da Neon:**
```bash
pg_dump "postgresql://...connection string..." | gzip > farmdb_$(date +%F).sql.gz
```

---

## Pontos de atenção

- **Egress**: 1 GB/mês grátis. Passar disso é cobrado. Monitore em
  Billing → Reports se o acesso crescer muito.
- **Artifact Registry**: 0.5 GB. Duas versões da imagem já estouram — apague as antigas.
- **Autosuspend da Neon**: o banco hiberna após ~5 min sem uso e leva ~1-2s para
  acordar. Soma com o cold start do Cloud Run no primeiro acesso.
- **Swagger**: `SecurityConfig` manda `anyRequest()` para `hasRole("ADMIN")`, então
  `/swagger-ui.html` responde 401/403. Comportamento já existente.
- **Conta de demonstração**: `demo_data.sql` cria `demo@quantaplanta.com` / `quanta123`
  (2 safras, 15 transações). O `mock_data.sql` é seed de desenvolvimento e não vai
  para produção; para restaurar a demo depois de visitantes mexerem nela, reaplique
  o `demo_data.sql` — ele é re-executável.
  O site é público, então trate como conta de vitrine.

---

## Se o Google recusar o cartão

O mesmo `Dockerfile.allinone` sobe no **Render** sem alteração — o Render também
injeta `PORT` e espera um container que escute nela:

1. render.com → New → Web Service → conecte o repositório (não pede cartão)
2. Runtime **Docker**, Dockerfile Path `Dockerfile.allinone`
3. Adicione as mesmas variáveis de ambiente (`CORS_ORIGINS` = URL `.onrender.com`)
4. Banco: a mesma Neon

Diferença: o free do Render hiberna após 15 min e o cold start é ~50s, contra
~15-25s do Cloud Run.
