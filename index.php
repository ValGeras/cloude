<?php
$email = 'info@vvger.ru';
$brand = 'VVGER';

$services = [
    ['title' => 'Ремонт компьютеров и ноутбуков', 'text' => 'Диагностика и устранение неисправностей любой сложности — от зависаний до полного отказа техники.'],
    ['title' => 'Чистка от пыли и замена термопасты', 'text' => 'Профилактика перегрева, снижение шума кулеров, продление срока службы устройства.'],
    ['title' => 'Замена комплектующих', 'text' => 'Апгрейд и замена материнских плат, блоков питания, накопителей, оперативной памяти, матриц ноутбуков.'],
    ['title' => 'Установка и настройка ОС', 'text' => 'Windows, Linux, драйверы и необходимый софт — с переносом ваших файлов и настроек.'],
    ['title' => 'Удаление вирусов и оптимизация', 'text' => 'Чистка от вредоносного ПО, ускорение работы системы, настройка автозагрузки.'],
    ['title' => 'Восстановление данных', 'text' => 'Спасение файлов при сбоях накопителя, случайном удалении или форматировании.'],
    ['title' => 'Ремонт после залития', 'text' => 'Разборка, промывка, просушка и восстановление работоспособности платы.'],
];

$advantages = [
    ['title' => 'Бесплатная диагностика', 'text' => 'Определяем причину неисправности до начала платных работ.'],
    ['title' => 'Гарантия на работы', 'text' => 'Даём письменную гарантию на выполненный ремонт и установленные комплектующие.'],
    ['title' => 'Прозрачные цены', 'text' => 'Озвучиваем стоимость заранее — никаких сюрпризов в итоговом чеке.'],
    ['title' => 'Быстрый срок', 'text' => 'Большинство типовых работ выполняем в течение 1–2 дней.'],
];

$steps = [
    ['n' => '1', 'title' => 'Заявка', 'text' => 'Пишете нам на почту и описываете проблему.'],
    ['n' => '2', 'title' => 'Диагностика', 'text' => 'Бесплатно определяем причину и стоимость ремонта.'],
    ['n' => '3', 'title' => 'Согласование', 'text' => 'Подтверждаете стоимость — приступаем к работе.'],
    ['n' => '4', 'title' => 'Готово', 'text' => 'Забираете исправную технику с гарантией.'],
];
?>
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= htmlspecialchars($brand) ?> — ремонт компьютерной техники</title>
<meta name="description" content="Ремонт компьютеров и ноутбуков: диагностика, чистка, замена комплектующих, установка ОС, удаление вирусов, восстановление данных. Гарантия на работы.">
<style>
  :root{
    --bg: #0b1220;
    --bg-elevated: #121a2e;
    --border: #1f2a44;
    --text: #f1f5f9;
    --text-muted: #94a3b8;
    --accent: #22d3ee;
    --accent-strong: #06b6d4;
  }
  *{ box-sizing: border-box; }
  html{ scroll-behavior: smooth; }
  body{
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    line-height: 1.5;
  }
  a{ color: inherit; }
  .container{
    max-width: 1080px;
    margin: 0 auto;
    padding: 0 24px;
  }
  header.site{
    position: sticky;
    top: 0;
    z-index: 10;
    background: rgba(11,18,32,0.85);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid var(--border);
  }
  .nav{
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 24px;
    max-width: 1080px;
    margin: 0 auto;
  }
  .logo{
    font-weight: 800;
    font-size: 1.25rem;
    letter-spacing: 0.02em;
  }
  .logo span{ color: var(--accent); }
  .nav-links{
    display: flex;
    gap: 24px;
    font-size: 0.95rem;
    color: var(--text-muted);
  }
  .nav-links a:hover{ color: var(--text); }
  .btn{
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 24px;
    border-radius: 10px;
    font-weight: 600;
    text-decoration: none;
    border: 1px solid transparent;
    transition: transform 0.15s ease, background 0.15s ease;
  }
  .btn-primary{
    background: linear-gradient(135deg, var(--accent), var(--accent-strong));
    color: #06111f;
  }
  .btn-primary:hover{ transform: translateY(-1px); }
  .btn-ghost{
    border-color: var(--border);
    color: var(--text);
  }
  .btn-ghost:hover{ border-color: var(--accent); }
  .btn-small{ padding: 8px 16px; font-size: 0.9rem; }

  .hero{
    padding: 96px 0 72px;
    text-align: center;
  }
  .eyebrow{
    display: inline-block;
    padding: 6px 14px;
    border: 1px solid var(--border);
    border-radius: 999px;
    color: var(--accent);
    font-size: 0.85rem;
    margin-bottom: 24px;
  }
  h1{
    font-size: clamp(2rem, 5vw, 3.25rem);
    margin: 0 0 20px;
    font-weight: 800;
    letter-spacing: -0.02em;
  }
  .hero p.lead{
    color: var(--text-muted);
    font-size: 1.15rem;
    max-width: 620px;
    margin: 0 auto 36px;
  }
  .hero-actions{
    display: flex;
    gap: 16px;
    justify-content: center;
    flex-wrap: wrap;
  }

  section{ padding: 64px 0; }
  section.alt{ background: var(--bg-elevated); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); }
  .section-head{
    text-align: center;
    max-width: 560px;
    margin: 0 auto 48px;
  }
  .section-head h2{
    font-size: clamp(1.5rem, 3vw, 2rem);
    margin: 0 0 12px;
  }
  .section-head p{ color: var(--text-muted); margin: 0; }

  .grid{
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 20px;
  }
  .card{
    background: var(--bg-elevated);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 24px;
  }
  section.alt .card{ background: var(--bg); }
  .card h3{ margin: 0 0 8px; font-size: 1.05rem; }
  .card p{ margin: 0; color: var(--text-muted); font-size: 0.95rem; }

  .advantages{
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  }
  .advantages .card{ text-align: center; }

  .steps{
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
  .step-num{
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--accent), var(--accent-strong));
    color: #06111f;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 800;
    margin-bottom: 12px;
  }

  .cta{
    text-align: center;
    padding: 72px 24px;
  }
  .cta-box{
    max-width: 640px;
    margin: 0 auto;
    background: var(--bg-elevated);
    border: 1px solid var(--border);
    border-radius: 20px;
    padding: 48px 32px;
  }
  .cta-box h2{ margin: 0 0 12px; font-size: 1.6rem; }
  .cta-box p{ color: var(--text-muted); margin: 0 0 28px; }
  .email-link{
    font-size: 1.15rem;
    font-weight: 700;
    color: var(--accent);
    text-decoration: none;
  }

  footer{
    border-top: 1px solid var(--border);
    padding: 32px 0;
    color: var(--text-muted);
    font-size: 0.9rem;
    text-align: center;
  }
  footer a{ color: var(--text-muted); text-decoration: underline; }

  @media (max-width: 640px){
    .nav-links{ display: none; }
    .hero{ padding: 64px 0 48px; }
  }
</style>
</head>
<body>

<header class="site">
  <div class="nav">
    <div class="logo"><?= htmlspecialchars($brand) ?><span>.</span></div>
    <nav class="nav-links">
      <a href="#services">Услуги</a>
      <a href="#advantages">Почему мы</a>
      <a href="#process">Как это работает</a>
      <a href="#contact">Контакты</a>
    </nav>
    <a class="btn btn-primary btn-small" href="mailto:<?= htmlspecialchars($email) ?>">Написать нам</a>
  </div>
</header>

<main>
  <section class="hero">
    <div class="container">
      <span class="eyebrow">Ремонт компьютерной техники</span>
      <h1>Чиним компьютеры и ноутбуки быстро,<br>честно и с гарантией</h1>
      <p class="lead">
        Бесплатная диагностика, прозрачные цены и гарантия на все виды работ.
        Расскажите, что случилось с вашей техникой — мы поможем.
      </p>
      <div class="hero-actions">
        <a class="btn btn-primary" href="mailto:<?= htmlspecialchars($email) ?>?subject=Заявка%20на%20ремонт">Оставить заявку</a>
        <a class="btn btn-ghost" href="#services">Смотреть услуги</a>
      </div>
    </div>
  </section>

  <section id="services">
    <div class="container">
      <div class="section-head">
        <h2>Что мы ремонтируем</h2>
        <p>Полный цикл работ с компьютерами и ноутбуками — от диагностики до восстановления данных.</p>
      </div>
      <div class="grid">
        <?php foreach ($services as $s): ?>
        <div class="card">
          <h3><?= htmlspecialchars($s['title']) ?></h3>
          <p><?= htmlspecialchars($s['text']) ?></p>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <section id="advantages" class="alt">
    <div class="container">
      <div class="section-head">
        <h2>Почему выбирают нас</h2>
        <p>Работаем так, как хотели бы, чтобы работали с нашей собственной техникой.</p>
      </div>
      <div class="grid advantages">
        <?php foreach ($advantages as $a): ?>
        <div class="card">
          <h3><?= htmlspecialchars($a['title']) ?></h3>
          <p><?= htmlspecialchars($a['text']) ?></p>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <section id="process">
    <div class="container">
      <div class="section-head">
        <h2>Как это работает</h2>
        <p>Четыре простых шага от заявки до исправной техники.</p>
      </div>
      <div class="grid steps">
        <?php foreach ($steps as $s): ?>
        <div class="card">
          <div class="step-num"><?= htmlspecialchars($s['n']) ?></div>
          <h3><?= htmlspecialchars($s['title']) ?></h3>
          <p><?= htmlspecialchars($s['text']) ?></p>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <section id="contact" class="cta">
    <div class="cta-box">
      <h2>Опишите проблему — ответим в ближайшее время</h2>
      <p>Напишите на почту, что случилось с вашей техникой: мы уточним детали и назначим бесплатную диагностику.</p>
      <a class="email-link" href="mailto:<?= htmlspecialchars($email) ?>"><?= htmlspecialchars($email) ?></a>
    </div>
  </section>
</main>

<footer>
  <div class="container">
    &copy; <?= date('Y') ?> <?= htmlspecialchars($brand) ?>. Ремонт компьютерной техники. ·
    <a href="mailto:<?= htmlspecialchars($email) ?>"><?= htmlspecialchars($email) ?></a>
  </div>
</footer>

</body>
</html>
