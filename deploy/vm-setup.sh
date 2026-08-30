#!/usr/bin/env bash
# Prepara uma VM Ubuntu recem-criada na Oracle Cloud para rodar a stack.
# Uso:  bash vm-setup.sh
# Depois de rodar, FACA LOGOUT E LOGIN de novo (o grupo docker so vale na nova sessao).
set -euo pipefail

echo "==> 1/4 Pacotes base"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    ca-certificates curl gnupg git

echo "==> 2/4 Liberando portas 80 e 443"
# Pegadinha classica da Oracle: as imagens Ubuntu vem com uma regra REJECT no
# fim da chain INPUT que bloqueia tudo alem da porta 22, INDEPENDENTEMENTE do
# que a Security List da VCN permite. Sem isso o Caddy nao emite o certificado.
if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    echo "    ufw: regras adicionadas"
else
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iptables-persistent
    # Insere no topo da chain, garantidamente antes do REJECT final.
    sudo iptables -I INPUT 1 -p tcp --dport 80  -j ACCEPT
    sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
    sudo netfilter-persistent save
    echo "    iptables: regras adicionadas e persistidas"
fi

echo "==> 3/4 Docker Engine + plugin compose"
if ! command -v docker >/dev/null 2>&1; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

echo "==> 4/4 Verificacao"
docker --version
docker compose version

cat <<'MSG'

Pronto. Agora:
  1. Saia e entre de novo no SSH (para o grupo docker valer).
  2. git clone <repo> && cd farm-management-api
  3. cp .env.prod.example .env  e preencha os valores
  4. docker compose -f docker-compose.prod.yaml up -d --build
MSG
