# Подключение домена vvger.ru к серверу Ubuntu

Скрипт `scripts/setup-vvger-domain.sh` настраивает Ubuntu-сервер так, чтобы домен
`vvger.ru` (и `www.vvger.ru`) обслуживался через Nginx с бесплатным SSL-сертификатом
от Let's Encrypt, а также (по умолчанию) поднимает PHP-FPM и MySQL для полноценного
PHP-сайта.

## Что делает скрипт

1. Проверяет, что A-запись домена указывает на IP этого сервера.
2. Устанавливает `nginx`, `certbot` (плагин `python3-certbot-nginx`), `ufw`.
3. Устанавливает `php-fpm` с расширениями (`mysql`, `mbstring`, `xml`, `curl`, `zip`,
   `gd`, `bcmath`) — если используется режим статического/PHP-сайта (см. ниже).
4. Устанавливает `mysql-server`, создаёт базу данных и отдельного пользователя для
   сайта, сохраняет данные для подключения в `/root/.vvger_db_credentials`
   (доступен только root). MySQL слушает только `localhost`, порт 3306 наружу
   не открывается.
5. Открывает в firewall порты SSH, 80 и 443.
6. Создаёт конфиг Nginx:
   - как reverse proxy на локальное приложение (если задан `APP_PORT`), либо
   - как сервер PHP/статических файлов (по умолчанию `/var/www/vvger.ru`,
     `.php`-файлы обрабатываются через PHP-FPM).
7. Выпускает и подключает SSL-сертификат Let's Encrypt с автоматическим
   редиректом с HTTP на HTTPS, включает автопродление.

## Перед запуском

1. У регистратора домена `vvger.ru` добавьте DNS-записи, указывающие на публичный
   IP сервера:
   - `A    vvger.ru       -> <IP сервера>`
   - `A    www.vvger.ru   -> <IP сервера>` (или `CNAME www -> vvger.ru`)
2. Дождитесь распространения DNS (проверить: `dig +short vvger.ru`).
3. Убедитесь, что порты 80/443 не заняты другими сервисами на сервере.

## Использование

PHP-сайт с базой MySQL, файлы в `/var/www/vvger.ru` (режим по умолчанию):

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com \
  ./scripts/setup-vvger-domain.sh
```

Данные для подключения к БД (хост, имя базы, пользователь, пароль) окажутся в
`/root/.vvger_db_credentials`. Свои значения можно задать явно:

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com \
  DB_NAME=vvger DB_USER=vvger DB_PASS='свой-пароль' \
  ./scripts/setup-vvger-domain.sh
```

Проксирование запросов на локальное приложение (например, Node.js на порту 3000;
PHP при этом не настраивается, MySQL по-прежнему поднимается, если нужен):

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com APP_PORT=3000 \
  ./scripts/setup-vvger-domain.sh
```

Отключить PHP и/или MySQL, если они не нужны:

```bash
sudo DOMAIN=vvger.ru EMAIL=you@example.com ENABLE_PHP=false ENABLE_MYSQL=false \
  ./scripts/setup-vvger-domain.sh
```

После успешного запуска сайт будет доступен по адресу `https://vvger.ru`.
