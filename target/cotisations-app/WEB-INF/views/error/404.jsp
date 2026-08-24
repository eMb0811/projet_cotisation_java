<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 — Page introuvable | UCAD Cotisations</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0d1117 0%, #1a237e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
            padding: 20px;
        }
        .container { max-width: 500px; }
        .error-code {
            font-size: 120px;
            font-weight: 700;
            line-height: 1;
            background: linear-gradient(135deg, #f57f17, #ffa000);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 8px;
        }
        .icon { font-size: 48px; margin-bottom: 16px; opacity: 0.7; }
        h1 { font-size: 24px; font-weight: 600; margin-bottom: 12px; }
        p { color: rgba(255,255,255,0.6); font-size: 15px; line-height: 1.6; margin-bottom: 32px; }
        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(135deg, #f57f17, #ffa000);
            color: white; text-decoration: none; padding: 12px 28px;
            border-radius: 10px; font-weight: 600; font-size: 14px;
            transition: all 0.2s; box-shadow: 0 4px 20px rgba(245,127,23,0.35);
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(245,127,23,0.5); }
        .btn-outline {
            background: transparent; border: 1px solid rgba(255,255,255,0.3);
            color: rgba(255,255,255,0.8); margin-left: 12px;
        }
        .btn-outline:hover { background: rgba(255,255,255,0.1); box-shadow: none; }
        .divider { width: 60px; height: 3px; background: linear-gradient(90deg,#f57f17,#ffa000); border-radius: 2px; margin: 20px auto; }
    </style>
</head>
<body>
<div class="container">
    <div class="icon"><i class="bi bi-map"></i></div>
    <div class="error-code">404</div>
    <div class="divider"></div>
    <h1>Page introuvable</h1>
    <p>La page que vous recherchez n'existe pas ou a été déplacée.<br>Vérifiez l'URL ou retournez au tableau de bord.</p>
    <div>
        <a href="<%= request.getContextPath() %>/dashboard" class="btn">
            <i class="bi bi-grid-1x2-fill"></i> Tableau de bord
        </a>
        <a href="javascript:history.back()" class="btn btn-outline">
            <i class="bi bi-arrow-left"></i> Retour
        </a>
    </div>
    <p style="margin-top:32px;font-size:12px;opacity:0.3">UCAD — Système de Gestion des Cotisations</p>
</div>
</body>
</html>
