# Deploy — Farm Management

Stack de produção: **3 containers numa VM só**, servidos por uma única origem HTTPS.

```
Internet ──https──▶ [web] Caddy ──/api/*──▶ [api] Spring Boot :8080
                        │                        │
                        └── / ──▶ Vue (SPA)      ▼
                                          [database] Postgres 18
```

Servir tudo sob a mesma origem é o que faz o cookie JWT
(`HttpOnly; Secure; SameSite=None`, definido em `security/CookieHandlerImpl.java`)
funcionar sem nenhuma alteração de código, e elimina CORS.

---

## Parte 1 — Criar a VM (console web da Oracle, você faz)

1. **Conta**: cloud.oracle.com → criar conta gratuita.
   O cartão de crédito é só verificação de identidade (cobra ~R$1 e estorna).
   **Home Region: Brazil East (São Paulo)** — não dá para trocar depois.

2. **Instância**: Compute → Instances → Create instance
   - Image: **Ubuntu 24.04**
   - Shape: **VM.Standard.A1.Flex**, **2 OCPU / 12 GB RAM**
     (o limite Always Free é 4 OCPU / 24 GB; pedir menos aumenta a chance de haver capacidade)
   - **Salve a chave SSH privada** que o console oferece para download.
   - Anote o **IP público**.

   > **"Out of host capacity"** é comum no shape ARM. Tente outro Availability Domain,
   > ou 1 OCPU / 6 GB, ou repita alguns minutos depois.

3. **Abrir as portas na VCN**: Networking → Virtual Cloud Networks → sua VCN →
   Security Lists → Default → Add Ingress Rules:
   - Source `0.0.0.0/0`, IP Protocol TCP, Destination Port **80**
   - Source `0.0.0.0/0`, IP Protocol TCP, Destination Port **443**

4. **Domínio**: duckdns.org → login com Google → criar um subdomínio
   (ex: `agrogestao`) → colar o **IP público da VM** no campo `current ip` → update.
   Confira com `nslookup agrogestao.duckdns.org`.

---

## Parte 2 — Configurar a VM

```bash
# Do seu Windows (Git Bash / PowerShell):
chmod 600 ssh-key.key                 # no Git Bash; no Windows puro use icacls
ssh -i ssh-key.key ubuntu@<IP-PUBLICO>
```

Já dentro da VM:

```bash
git clone https://github.com/murilo-l1/farm-management.git
cd farm-management
bash deploy/vm-setup.sh
exit                                   # logout obrigatório: o grupo docker só vale na próxima sessão
```

O `vm-setup.sh` instala Docker + compose e **libera as portas 80/443 no iptables**.
Esse passo do iptables é essencial: as imagens Ubuntu da Oracle vêm com um `REJECT`
no fim da chain `INPUT` que bloqueia tudo além da porta 22, **independentemente**
do que a Security List da VCN permite. Sem isso o Caddy nem consegue emitir o certificado.

---

## Parte 3 — Subir a aplicação

Reconecte por SSH e:

```bash
cd farm-management
cp .env.prod.example .env
nano .env
```

Preencha:

```ini
SITE_ADDRESS=agrogestao.duckdns.org          # só o host, sem https:// e sem porta
CORS_ORIGINS=https://agrogestao.duckdns.org  # com https://
POSTGRES_DB=farmdb
POSTGRES_USER=farmadmin
POSTGRES_PASSWORD=<openssl rand -base64 24>
JWT_SECRET=<openssl rand -base64 64 | tr -d '\n'>
HTTP_PORT=80
HTTPS_PORT=443
```

> `JWT_SECRET` **precisa ser Base64 válido** — é decodificado no boot em `JwtHandlerImpl`.
> Gere os dois segredos na própria VM e **nunca** reutilize os valores de desenvolvimento.
>
> Se gerar os segredos no **Windows** (Git Bash), use `tr -d '
'` e não só `tr -d '
'`:
> o `openssl` do Windows termina a linha com CRLF, o `` fica no valor e o Spring falha no
> boot com `IllegalArgumentException: Illegal base64 character d` (`0x0d` = CR).

```bash
docker compose -f docker-compose.prod.yaml up -d --build
docker compose -f docker-compose.prod.yaml logs -f
```

O primeiro build leva ~5–10 min (baixa Gradle, dependências Spring e npm).
Aguarde o Caddy anunciar o certificado emitido e acesse `https://agrogestao.duckdns.org`.

---

## Operação

```bash
# Estado dos containers
docker compose -f docker-compose.prod.yaml ps

# Logs de um serviço
docker compose -f docker-compose.prod.yaml logs -f api

# Publicar uma atualização
git pull && docker compose -f docker-compose.prod.yaml up -d --build

# Backup manual
bash deploy/backup.sh
```

**Backup automático** — instalar no cron da VM:
```bash
crontab -e
# 0 3 * * * /home/ubuntu/farm-management/deploy/backup.sh >> /home/ubuntu/backup.log 2>&1
```

**Restaurar um backup:**
```bash
gunzip -c ~/backups/farmdb_2026-08-30_0300.sql.gz \
  | docker compose -f docker-compose.prod.yaml exec -T database psql -U farmadmin -d farmdb
```

---

## Pontos de atenção

- **`init.sql` e `mock_data.sql` rodam só uma vez**, no primeiro boot com o volume vazio.
  Como `spring.jpa.hibernate.ddl-auto=validate`, o schema precisa existir antes da API subir —
  por isso o `api` só inicia depois do healthcheck do `database` passar.
  Para recomeçar do zero: `docker compose -f docker-compose.prod.yaml down -v` (**apaga os dados**).
- **Conta de demonstração**: `mock_data.sql` cria `teste@email.com` / `teste123`.
  Como o site é público, trate isso como conta de vitrine — os dados dela ficam visíveis a qualquer visitante.
- **Swagger não abre em produção**: `SecurityConfig` manda `anyRequest()` para `hasRole("ADMIN")`,
  então `/swagger-ui.html` responde 401/403. É o comportamento já existente, não uma regressão.
- **Ociosidade na Oracle**: instâncias Always Free com CPU baixa por 7 dias seguidos podem ser
  recuperadas. Com pouco tráfego, vale um keepalive no cron da própria VM:
  `*/10 * * * * curl -fsS https://agrogestao.duckdns.org > /dev/null`
- **Certificados** persistem no volume `caddy-data`; um `down` sem `-v` não os perde.
  O Let's Encrypt limita 5 emissões por domínio por semana — evite `down -v` repetido.

---

## Teste local da mesma stack

```bash
cp .env.prod.example .env
# SITE_ADDRESS=:80   CORS_ORIGINS=http://localhost:8090   HTTP_PORT=8090   HTTPS_PORT=8443
docker compose -f docker-compose.prod.yaml up -d --build
# http://localhost:8090
```

`SITE_ADDRESS=:80` faz o Caddy servir HTTP puro sem TLS. O cookie `Secure` funciona
mesmo assim porque navegadores tratam `localhost` como origem segura.
