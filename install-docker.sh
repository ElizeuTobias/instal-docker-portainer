#!/bin/bash

# Script de instalação automática do Docker, Docker Compose e Portainer CE
# Criado em: 14/05/2025

echo "======================================================"
echo "Iniciando instalação do Docker, Docker Compose e Portainer"
echo "======================================================"

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script como root ou usando sudo."
  exit 1
fi

# Capturar o nome de usuário não-root para adicionar ao grupo docker
if [ "$SUDO_USER" ]; then
  USER_NAME="$SUDO_USER"
else
  USER_NAME="$USER"
fi

echo "======================================================"
echo "1 - Atualizando o Sistema"
echo "======================================================"
apt update

echo "======================================================"
echo "2 - Instalando pré-requisitos"
echo "======================================================"
apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "======================================================"
echo "3 - Adicionando chave GPG"
echo "======================================================"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "======================================================"
echo "4 - Adicionando repositório Docker ao Ubuntu"
echo "======================================================"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "======================================================"
echo "5 - Atualizando a lista de pacotes"
echo "======================================================"
apt update

echo "======================================================"
echo "6 - Instalando o Docker"
echo "======================================================"
apt install -y docker-ce

echo "======================================================"
echo "7 - Verificando a instalação do Docker"
echo "======================================================"
systemctl status docker --no-pager
docker --version

echo "======================================================"
echo "8 - Adicionando usuário ao grupo docker"
echo "======================================================"
usermod -aG docker ${USER_NAME}
echo "Usuário ${USER_NAME} adicionado ao grupo docker"

echo "======================================================"
echo "Instalando o Docker Compose no Ubuntu"
echo "======================================================"

echo "1 - Criando diretório para o Docker Compose"
mkdir -p /home/${USER_NAME}/.docker/cli-plugins/

echo "2 - Baixando o Docker Compose"
curl -SL https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-x86_64 -o /home/${USER_NAME}/.docker/cli-plugins/docker-compose

echo "3 - Dando permissões de execução"
chmod +x /home/${USER_NAME}/.docker/cli-plugins/docker-compose
chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.docker

echo "4 - Verificando a instalação do Docker Compose"
sudo -u ${USER_NAME} docker compose version || echo "Docker Compose será disponível após reiniciar a sessão"

echo "======================================================"
echo "Instalando Portainer CE"
echo "======================================================"

echo "1 - Criando volume para o Portainer Server"
docker volume create portainer_data

echo "2 - Baixando e instalando o container Portainer Server"
docker run -d -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts

echo "======================================================"
echo "Instalação Concluída!"
echo "======================================================"
echo "Docker instalado: $(docker --version)"
echo "Portainer CE está rodando"
echo "Acesse o Portainer: http://$(hostname -I | awk '{print $1}'):9000"
echo ""
echo "IMPORTANTE: Para que as alterações de grupo entrem em vigor, você precisa fazer logout e login novamente."
echo "======================================================"
