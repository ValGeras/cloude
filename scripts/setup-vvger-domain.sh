#!/usr/bin/env bash
#
# Подключение домена vvger.ru к серверу Ubuntu:
#   - установка и настройка Nginx
#   - выпуск бесплатного SSL-сертификата Let's Encrypt (certbot)
#   - настройка firewall (ufw)
#
# Использование:
#   sudo DOMAIN=vvger.ru EMAIL=you@example.com APP_PORT=3000 ./setup-vvger-domain.sh
#
# Перед запуском:
#   1. У домена vvger.ru должна быть A-запись, указывающая на IP этого сервера
#      (и, при необходимости, отдельная A/CNAME запись для www.vvger.ru).
#      Проверить: dig +short vvger.ru
#   2. Порты 80 и 443 должны быть открыты и не заняты другими сервисами.

set -euo pipefail

DOMAIN="${DOMAIN:-vvger.ru}"
WWW_DOMAIN="www.${DOMAIN}"
EMAIL="${EMAIL:-}"
# Порт локального приложения, на который Nginx будет проксировать запросы.
# Если у вас статический сайт, а не приложение — оставьте пусто и используйте
# ветку STATIC_ROOT ниже вместо APP_PORT.
APP_PORT="${APP_PORT:-}"
# Путь к статическим файлам сайта (используется, если APP_PORT не задан).
STATIC_ROOT="${STATIC_ROOT:-/var/www/${DOMAIN}}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запустите скрипт с правами root (sudo)." >&2
  exit 1
fi

echo "==> Проверка, что DNS домена ${DOMAIN} указывает на этот сервер"
SERVER_IP="$(curl -fsS4 https://api.ipify.org || true)"
DOMAIN_IP="$(dig +short A "${DOMAIN}" @1.1.1.1 | tail -n1 || true)"
if [[ -n "${SERVER_IP}" && -n "${DOMAIN_IP}" && "${SERVER_IP}" != "${DOMAIN_IP}" ]]; then
  echo "ВНИМАНИЕ: A-запись ${DOMAIN} (${DOMAIN_IP:-нет}) не совпадает с IP сервера (${SERVER_IP})." >&2
  echo "Продолжаю настройку Nginx, но certbot не сможет выпустить сертификат, пока DNS не обновится." >&2
fi

echo "==> Установка пакетов (nginx, certbot, ufw)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx certbot python3-certbot-nginx ufw dnsutils curl

echo "==> Настройка firewall"
ufw allow OpenSSH >/dev/null
ufw allow "Nginx Full" >/dev/null
if ! ufw status | grep -q "Status: active"; then
  ufw --force enable
fi

NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}"

if [[ -n "${APP_PORT}" ]]; then
  echo "==> Настройка Nginx как reverse proxy на localhost:${APP_PORT}"
  cat > "${NGINX_CONF}" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
else
  echo "==> Настройка Nginx для отдачи статических файлов из ${STATIC_ROOT}"
  mkdir -p "${STATIC_ROOT}"
  if [[ ! -f "${STATIC_ROOT}/index.html" ]]; then
    echo "<h1>${DOMAIN}</h1>" > "${STATIC_ROOT}/index.html"
  fi
  chown -R www-data:www-data "${STATIC_ROOT}"
  cat > "${NGINX_CONF}" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${STATIC_ROOT};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
fi

ln -sf "${NGINX_CONF}" "/etc/nginx/sites-enabled/${DOMAIN}"
rm -f /etc/nginx/sites-enabled/default

echo "==> Проверка конфигурации Nginx"
nginx -t
systemctl reload nginx
systemctl enable nginx >/dev/null

echo "==> Выпуск SSL-сертификата Let's Encrypt"
if [[ -z "${EMAIL}" ]]; then
  echo "EMAIL не задан — certbot будет запущен без --email (без уведомлений об истечении сертификата)." >&2
  CERTBOT_EMAIL_ARGS=(--register-unsafely-without-email)
else
  CERTBOT_EMAIL_ARGS=(--email "${EMAIL}")
fi

certbot --nginx \
  -d "${DOMAIN}" -d "${WWW_DOMAIN}" \
  "${CERTBOT_EMAIL_ARGS[@]}" \
  --agree-tos --redirect --non-interactive

echo "==> Автопродление сертификата"
systemctl enable --now certbot.timer >/dev/null 2>&1 || true
certbot renew --dry-run

echo "==> Готово. Сайт должен быть доступен по адресу: https://${DOMAIN}"
