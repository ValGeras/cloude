#!/usr/bin/env bash
#
# Разовая подготовка сервера для автодеплоя сайта из GitHub Actions.
# Создаёт отдельного пользователя deploy с SSH-доступом только по ключу
# и минимальными sudo-правами (перезагрузка nginx/php-fpm, chown сайта) —
# без полного root-доступа для CI.
#
# Использование (на сервере, от root, один раз):
#   sudo DEPLOY_PATH=/var/www/vvger.ru \
#        DEPLOY_PUBLIC_KEY="ssh-ed25519 AAAA... github-actions@vvger" \
#        ./prepare-deploy-user.sh
#
# Приватную часть ключа (DEPLOY_SSH_KEY) добавьте в секреты репозитория GitHub,
# публичную передайте в этот скрипт через DEPLOY_PUBLIC_KEY.
# Сгенерировать пару ключей локально:
#   ssh-keygen -t ed25519 -f deploy_key -N "" -C "github-actions@vvger"

set -euo pipefail

DEPLOY_USER="${DEPLOY_USER:-deploy}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/vvger.ru}"
DEPLOY_PUBLIC_KEY="${DEPLOY_PUBLIC_KEY:-}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запустите скрипт с правами root (sudo)." >&2
  exit 1
fi

if [[ -z "${DEPLOY_PUBLIC_KEY}" ]]; then
  echo "Задайте DEPLOY_PUBLIC_KEY (публичный SSH-ключ для GitHub Actions)." >&2
  exit 1
fi

echo "==> Создание пользователя ${DEPLOY_USER}"
# Шелл должен быть настоящим (bash), а не /usr/sbin/nologin — иначе sshd не
# сможет выполнить команду rsync/ssh при неинтерактивном подключении из CI.
if ! id "${DEPLOY_USER}" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "${DEPLOY_USER}"
else
  usermod --shell /bin/bash "${DEPLOY_USER}"
fi

mkdir -p "/home/${DEPLOY_USER}/.ssh"
echo "${DEPLOY_PUBLIC_KEY}" > "/home/${DEPLOY_USER}/.ssh/authorized_keys"
chmod 700 "/home/${DEPLOY_USER}/.ssh"
chmod 600 "/home/${DEPLOY_USER}/.ssh/authorized_keys"
chown -R "${DEPLOY_USER}:${DEPLOY_USER}" "/home/${DEPLOY_USER}/.ssh"

echo "==> Права на каталог сайта ${DEPLOY_PATH}"
mkdir -p "${DEPLOY_PATH}"
chown -R "${DEPLOY_USER}:www-data" "${DEPLOY_PATH}"
chmod -R g+rwX "${DEPLOY_PATH}"

echo "==> Скрипт перезагрузки сервисов (запускается через sudo без пароля)"
cat > /usr/local/sbin/vvger-reload-services.sh <<EOF
#!/usr/bin/env bash
set -euo pipefail
chown -R www-data:www-data "${DEPLOY_PATH}"
systemctl reload php*-fpm 2>/dev/null || true
systemctl reload nginx
EOF
chmod 700 /usr/local/sbin/vvger-reload-services.sh
chown root:root /usr/local/sbin/vvger-reload-services.sh

echo "==> Настройка sudo (только запуск скрипта выше, без пароля)"
cat > /etc/sudoers.d/vvger-deploy <<EOF
${DEPLOY_USER} ALL=(root) NOPASSWD: /usr/local/sbin/vvger-reload-services.sh
EOF
chmod 440 /etc/sudoers.d/vvger-deploy
visudo -c

echo "==> Готово."
echo "    Пользователь: ${DEPLOY_USER}"
echo "    Каталог сайта: ${DEPLOY_PATH}"
echo "    В GitHub Actions secrets укажите:"
echo "      DEPLOY_HOST=<IP или домен сервера>"
echo "      DEPLOY_USER=${DEPLOY_USER}"
echo "      DEPLOY_PATH=${DEPLOY_PATH}"
echo "      DEPLOY_SSH_KEY=<содержимое приватного ключа deploy_key>"
echo "      DEPLOY_PORT=22   # если отличается от 22"
