# Deploy — Railway

Um serviço só (imagem `Dockerfile.allinone`: Caddy + SPA + Spring Boot na mesma
origem) mais o Postgres gerenciado do próprio Railway.

```
Internet ──https──▶ Railway edge ──▶ serviço "app"
                                       Caddy :$PORT ──/api/*──▶ Spring :8081
                                         └── / ──▶ Vue (SPA)         │
                                                                     ▼
                                                        serviço "Postgres"
```

Mesma origem = cookie JWT funciona sem CORS e sem alteração de código.

> **Sobre custo:** o Railway não tem free tier permanente desde 2023 — dá um
> crédito único de US$ 5 no trial e depois cobra US$ 5/mês (Hobby). Para um mês
> de MVP o crédito do trial tende a cobrir. Se a ideia é ficar em R$ 0,00 de
> verdade e indefinidamente, Cloud Run + Neon (`docs/deploy-cloudrun.md`) ou Render +
> Neon continuam sendo os caminhos gratuitos.

---

## Passo 1 — Criar os serviços

1. railway.app → New Project → **Deploy from GitHub repo** → `murilo-l1/farm-management`
2. No mesmo projeto: **+ New** → **Database** → **Add PostgreSQL**
3. No serviço da aplicação: **Settings** → **Networking** → **Generate Domain**
   (gera o `*.up.railway.app`)

O `railway.toml` do repositório já aponta o build para `Dockerfile.allinone` —
sem ele o Railway usaria o `Dockerfile` da raiz, que empacota só o backend.

---

## Passo 2 — Aplicar o schema no Postgres

O Spring sobe com `ddl-auto=validate`: se o schema não existir, o serviço nem
inicia. O Postgres do Railway não executa `docker-entrypoint-initdb.d`, então
isso é manual e **precisa ser feito antes do primeiro deploy dar certo**.

No serviço Postgres → aba **Variables** → copie `DATABASE_PUBLIC_URL`
(a pública, não a `.railway.internal`), e rode do seu Windows:

```bash
psql "postgresql://postgres:SENHA@viaduct.proxy.rlwy.net:PORTA/railway" -f docker/init/init.sql
psql "postgresql://postgres:SENHA@viaduct.proxy.rlwy.net:PORTA/railway" -f docker/init/demo_data.sql
```

Sem `psql` instalado, dá para colar o conteúdo dos dois arquivos no **Data** →
**Query** do próprio serviço Postgres, nessa ordem.

O `demo_data.sql` cria a conta de vitrine `demo@quantaplanta.com` / `demo123`
(2 safras, 5 categorias, 3 parceiros, 15 transações). Ele é re-executável: para
restaurar a demo depois de visitantes mexerem nela, é só aplicar o arquivo de novo.
O `mock_data.sql` (`teste@email.com`, 10 safras) é seed de desenvolvimento e **não**
vai para produção.

---

## Passo 3 — Variáveis do serviço da aplicação

Em **Variables**, use *Raw Editor* e cole:

```ini
SPRING_PROFILES_ACTIVE=prod
JAVA_TOOL_OPTIONS=-Djava.net.preferIPv6Addresses=true

DB_URL=jdbc:postgresql://${{Postgres.PGHOST}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}}
DB_USER=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}

CORS_ORIGINS=https://${{RAILWAY_PUBLIC_DOMAIN}}

JWT_SECRET=cole-aqui-o-segredo-base64
TZ=America/Sao_Paulo
```

`SERVER_PORT=8081` já vem do Dockerfile e `PORT` é injetada pelo Railway — não
declare nenhuma das duas.

Gere o `JWT_SECRET` com **`tr -d '\r\n'`**, não só `tr -d '\n'`:

```bash
openssl rand -base64 64 | tr -d '\r\n'
```

No Windows o `openssl` termina a linha com CRLF; o `\r` fica no valor e o Spring
morre no boot com `IllegalArgumentException: Illegal base64 character d` (`0x0d` = CR).

---

## Os três detalhes que quebram o deploy no Railway

**1. `DATABASE_URL` não serve para o Spring.** O Railway expõe
`postgresql://user:senha@host:porta/db` — formato libpq, não JDBC. O Spring precisa
de `jdbc:postgresql://host:porta/db` com usuário e senha em propriedades separadas.
Por isso o `DB_URL` acima é montado a partir de `PGHOST`/`PGPORT`/`PGDATABASE`.

**2. A rede privada do Railway é IPv6-only.** O host `*.railway.internal` só
resolve em IPv6, e a JVM prefere IPv4 por padrão — a conexão falha sem erro óbvio.
É para isso que serve o `JAVA_TOOL_OPTIONS=-Djava.net.preferIPv6Addresses=true`.
(A alternativa seria usar o host público, mas aí o tráfego sai e volta pela
internet, contando como egress e ficando mais lento.)

**3. `RAILWAY_PUBLIC_DOMAIN` resolve o ovo-e-galinha do CORS.** O domínio só
existe depois do serviço criado, mas `CORS_ORIGINS` é obrigatória no boot.
A variável de referência é resolvida pelo Railway antes de injetar, então
`https://${{RAILWAY_PUBLIC_DOMAIN}}` já sobe com o valor certo no primeiro deploy.
Sem barra no fim — `SecurityConfig` usa `addAllowedOrigin`, que é match exato.

---

## Verificação

1. `https://<seu-app>.up.railway.app` carrega o login com cadeado válido
2. Login `demo@quantaplanta.com` / `demo123` → DevTools → Application → Cookies:
   `jwt` com `HttpOnly`, `Secure`, `SameSite=None`
3. F5 direto em `/dashboard` → não pode dar 404 (fallback do Caddy)
4. Dashboard renderiza os gráficos (prova que o demo_data chegou ao banco)
5. Criar conta nova em `/register` → deve ver tudo zerado

## Operação

```bash
# Logs
railway logs

# Backup
pg_dump "postgresql://...DATABASE_PUBLIC_URL..." | gzip > farmdb_$(date +%F).sql.gz
```

Atualizações: `git push` na `main` — o Railway rebuilda e redeploya sozinho.
