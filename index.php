<?php
$domain = $_SERVER['HTTP_HOST'] ?? 'vvger.ru';
$time = date('Y-m-d H:i:s');
?>
<!doctype html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <title>Привет, мир!</title>
    <style>
        body {
            font-family: system-ui, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background: #0f172a;
            color: #f8fafc;
        }
        h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        p { color: #94a3b8; }
    </style>
</head>
<body>
    <h1>Привет, мир!</h1>
    <p>Тестовая страница <?= htmlspecialchars($domain) ?> — PHP <?= phpversion() ?></p>
    <p>Сгенерировано: <?= htmlspecialchars($time) ?></p>
</body>
</html>
