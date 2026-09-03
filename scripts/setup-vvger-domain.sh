#!/usr/bin/env bash
#
# Подключение домена vvger.ru к серверу Ubuntu:
#   - установка и настройка Nginx
#   - установка PHP-FPM (для режима статического/PHP-сайта)
#   - установка и настройка MySQL с базой данных и пользователем под сайт
#   - выпуск бесплатного SSL-сертификата Let's Encrypt (certbot)
#   - настройка firewall (ufw)
#
# Использование:
#   sudo DOMAIN=vvger.ru EMAIL=you@example.com APP_PORT=3000 ./setup-vvger-domain.sh
#   sudo DOMAIN=vvger.ru EMAIL=you@example.com ./setup-vvger-domain.sh   # PHP-сайт + MySQL
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
# Если у вас PHP/статический сайт, а не отдельное приложение — оставьте пусто,
# тогда используется режим STATIC_ROOT (с поддержкой PHP через PHP-FPM).
APP_PORT="${APP_PORT:-}"
# Путь к файлам сайта (используется, если APP_PORT не задан).
STATIC_ROOT="${STATIC_ROOT:-/var/www/${DOMAIN}}"

# Установка PHP-FPM и создание PHP-локации в Nginx (только в режиме STATIC_ROOT).
ENABLE_PHP="${ENABLE_PHP:-true}"
# Установка MySQL и создание базы/пользователя под сайт.
ENABLE_MYSQL="${ENABLE_MYSQL:-true}"
DB_NAME="${DB_NAME:-vvger}"
DB_USER="${DB_USER:-vvger}"
# Если не задан — сгенерируется случайный и будет сохранён в файл с credentials.
DB_PASS="${DB_PASS:-}"
DB_CREDENTIALS_FILE="/root/.vvger_db_credentials"

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

PACKAGES=(nginx certbot python3-certbot-nginx ufw dnsutils curl rsync)
if [[ "${ENABLE_PHP}" == "true" && -z "${APP_PORT}" ]]; then
  PACKAGES+=(php-fpm php-mysql php-mbstring php-xml php-curl php-zip php-gd php-bcmath)
fi
if [[ "${ENABLE_MYSQL}" == "true" ]]; then
  PACKAGES+=(mysql-server)
fi

echo "==> Установка пакетов: ${PACKAGES[*]}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y "${PACKAGES[@]}"

echo "==> Настройка firewall"
ufw allow OpenSSH >/dev/null
ufw allow "Nginx Full" >/dev/null
if ! ufw status | grep -q "Status: active"; then
  ufw --force enable
fi

PHP_FPM_SOCK=""
if [[ "${ENABLE_PHP}" == "true" && -z "${APP_PORT}" ]]; then
  systemctl enable --now php*-fpm >/dev/null 2>&1 || true
  PHP_FPM_SOCK="$(find /run/php -name '*.sock' 2>/dev/null | head -n1)"
  if [[ -z "${PHP_FPM_SOCK}" ]]; then
    echo "Не удалось найти сокет PHP-FPM в /run/php." >&2
    exit 1
  fi
  echo "==> PHP-FPM запущен, сокет: ${PHP_FPM_SOCK}"
fi

if [[ "${ENABLE_MYSQL}" == "true" ]]; then
  echo "==> Настройка MySQL"
  systemctl enable --now mysql

  if [[ -z "${DB_PASS}" ]]; then
    DB_PASS="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9')"
  fi

  # Свежий mysql-server на Ubuntu аутентифицирует root через unix_socket,
  # поэтому от имени root (через sudo) пароль не нужен.
  mysql --protocol=socket -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

  cat > "${DB_CREDENTIALS_FILE}" <<EOF
DB_HOST=localhost
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
EOF
  chmod 600 "${DB_CREDENTIALS_FILE}"
  echo "==> Данные для подключения к MySQL сохранены в ${DB_CREDENTIALS_FILE} (root-only)"
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
  echo "==> Настройка Nginx для отдачи файлов из ${STATIC_ROOT}"
  mkdir -p "${STATIC_ROOT}"
  if [[ "${ENABLE_PHP}" == "true" ]]; then
    if [[ ! -f "${STATIC_ROOT}/index.php" && ! -f "${STATIC_ROOT}/index.html" ]]; then
      cat > "${STATIC_ROOT}/index.php" <<EOF
<?php echo "<h1>${DOMAIN}</h1>"; echo "<p>PHP " . phpversion() . " работает.</p>";
EOF
    fi
  elif [[ ! -f "${STATIC_ROOT}/index.html" ]]; then
    echo "<h1>${DOMAIN}</h1>" > "${STATIC_ROOT}/index.html"
  fi
  chown -R www-data:www-data "${STATIC_ROOT}"

  PHP_LOCATION=""
  INDEX_DIRECTIVE="index index.html;"
  TRY_FILES="try_files \$uri \$uri/ =404;"
  if [[ "${ENABLE_PHP}" == "true" ]]; then
    INDEX_DIRECTIVE="index index.php index.html;"
    TRY_FILES="try_files \$uri \$uri/ /index.php?\$query_string;"
    PHP_LOCATION="
    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass unix:${PHP_FPM_SOCK};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }"
  fi

  cat > "${NGINX_CONF}" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${STATIC_ROOT};
    ${INDEX_DIRECTIVE}

    location / {
        ${TRY_FILES}
    }
${PHP_LOCATION}
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
if [[ "${ENABLE_MYSQL}" == "true" ]]; then
  echo "==> Данные подключения к MySQL: ${DB_CREDENTIALS_FILE}"
fi
