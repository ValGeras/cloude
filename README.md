# Подключение домена vvger.ru к серверу Ubuntu

Скрипт `scripts/setup-vvger-domain.sh` настраивает Ubuntu-сервер так, чтобы домен
`vvger.ru` (и `www.vvger.ru`) обслуживался через Nginx с бесплатным SSL-сертификатом
от Let's Encrypt.

## Что делает скрипт

1. Проверяет, что A-запись домена указывает на IP этого сервера.
2. Устанавливает `nginx`, `certbot` (плагин `python3-certbot-nginx`), `ufw`.
3. Открывает в firewall порты SSH, 80 и 443.
4. Создаёт конфиг Nginx:
   - как reverse proxy на локальное приложение (если задан `APP_PORT`), либо
   - как сервер статических файлов (по умолчанию `/var/www/vvger.ru`).
5. Выпускает и подключает SSL-сертификат Let's Encrypt с автоматическим
   редиректом с HTTP на HTTPS, включает автопродление.

## Перед запуском

1. У регистратора домена `vvger.ru` добавьте DNS-записи, указывающие на публичный
   IP сервера:
   - `A    vvger.ru       -> <IP сервера>`
   - `A    www.vvger.ru   -> <IP сервера>` (или `CNAME www -> vvger.ru`)
2. Дождитесь распространения DNS (проверить: `dig +short vvger.ru`).
3. Убедитесь, что порты 80/443 не заняты другими сервисами на сервере.

## Использование

Проксирование запросов на локальное приложение (например, Node.js на порту 3000):

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com APP_PORT=3000 \
  ./scripts/setup-vvger-domain.sh
```

Отдача статического сайта из `/var/www/vvger.ru`:

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com \
  ./scripts/setup-vvger-domain.sh
```

После успешного запуска сайт будет доступен по адресу `https://vvger.ru`.
