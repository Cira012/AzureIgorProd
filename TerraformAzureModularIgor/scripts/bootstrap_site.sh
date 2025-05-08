###############################################################################
# 0. Logging setup (all output ➜ console + /var/log/baseline-YYYYMMDD-HHMMSS.log)
###############################################################################
LOGFILE="/var/log/baseline-$(date +%F_%H%M%S).log"
mkdir -p "$(dirname "$LOGFILE")"
exec &> >(tee -a "$LOGFILE")
PS4='+ $(date "+%F %T") | '
set -euo pipefail
set -x                                # comment out if you want quieter logs
export DEBIAN_FRONTEND=noninteractive

banner () { echo -e "\e[1;34m===> $*\e[0m"; }

banner "Enable Universe + refresh APT"
add-apt-repository -y universe
apt-get update -qq

banner "Install Nginx and snap-based Certbot"
apt-get install -y --no-install-recommends nginx snapd
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

###############################################################################
# 1. Parse args – email used for SSH-key comment
###############################################################################
EMAIL=${1:-}
[[ -z "$EMAIL" ]] && { echo "Usage: sudo $0 <email>" >&2; exit 1; }

###############################################################################
# 2. Core OS packages
###############################################################################
banner "System upgrade and essentials"
apt-get update -y && apt-get upgrade -y
apt-get install -y --no-install-recommends \
  build-essential curl wget ca-certificates gnupg lsb-release \
  software-properties-common ufw

###############################################################################
# 3. Python 3.13 (Deadsnakes)
###############################################################################
banner "Python 3.13 tool-chain"
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y python3.13 python3.13-venv python3.13-dev
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.13
python3.13 -m pip install --upgrade pip setuptools wheel

###############################################################################
# 4. Git & friends
###############################################################################
banner "Git and basic tooling"
apt-get install -y git htop

###############################################################################
# 5. Docker Engine + Compose plugin
###############################################################################
banner "Docker Engine & Compose plugin"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
usermod -aG docker "$SUDO_USER"
systemctl enable --now docker

###############################################################################
# 6. Node.js via nvm
###############################################################################
banner "Node LTS via system-wide nvm"
export NVM_DIR="/usr/local/nvm"
mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source "$NVM_DIR/nvm.sh"
NODE_VERSION='lts/*'
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

###############################################################################
# 7. Nginx reverse-proxy skeleton
###############################################################################
banner "Nginx reverse-proxy config"
rm -f /etc/nginx/sites-enabled/default
cat >/etc/nginx/sites-available/reverse-proxy <<'EOF'
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass         http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF
ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

###############################################################################
# 8. Certbot snap refresh (core already installed)
###############################################################################
banner "Certbot snap refresh"
snap install core --classic
snap refresh core

###############################################################################
# 9. Security hardening
###############################################################################
banner "UFW, Fail2Ban, unattended upgrades"
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw --force enable
apt-get install -y fail2ban unattended-upgrades
systemctl enable --now fail2ban
dpkg-reconfigure --priority=low unattended-upgrades

###############################################################################
# 10. Misc CLI goodies
###############################################################################
banner "Misc utilities"
apt-get install -y jq zip unzip

###############################################################################
# 11. SSH key for CI/CD
###############################################################################
banner "Generate GitHub Actions deploy key"
KEY_PATH="/home/$SUDO_USER/github_actions_key"
sudo -u "$SUDO_USER" ssh-keygen -t rsa -b 4096 -C "$EMAIL" \
  -f "$KEY_PATH" -N ""

###############################################################################
# 12. Cleanup
###############################################################################
banner "Cleanup & finish"
apt-get autoremove -y && apt-get clean