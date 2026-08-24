<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 — Erreur serveur | UCAD Cotisations</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0d1117 0%, #7f1010 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
            padding: 20px;
        }
        .container { max-width: 560px; }
        .error-code {
            font-size: 120px;
            font-weight: 700;
            line-height: 1;
            background: linear-gradient(135deg, #ef9a9a, #ef5350);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 8px;
        }
        .icon { font-size: 48px; margin-bottom: 16px; opacity: 0.8; color: #ef9a9a; }
        h1 { font-size: 24px; font-weight: 600; margin-bottom: 12px; }
        p { color: rgba(255,255,255,0.6); font-size: 15px; line-height: 1.6; margin-bottom: 20px; }
        .divider { width: 60px; height: 3px; background: linear-gradient(90deg,#ef5350,#c62828); border-radius: 2px; margin: 20px auto; }
        .error-detail {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(239,83,80,0.3);
            border-radius: 10px;
            padding: 14px 18px;
            text-align: left;
            margin-bottom: 28px;
            font-size: 12px;
            color: rgba(255,255,255,0.5);
            font-family: monospace;
            word-break: break-all;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(135deg, #1a237e, #283593);
            color: white; text-decoration: none; padding: 12px 28px;
            border-radius: 10px; font-weight: 600; font-size: 14px;
            transition: all 0.2s;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(26,35,126,0.5); }
        .btn-outline {
            background: transparent; border: 1px solid rgba(255,255,255,0.3);
            color: rgba(255,255,255,0.8); margin-left: 12px;
        }
        .btn-outline:hover { background: rgba(255,255,255,0.1); box-shadow: none; }
    </style>
</head>
<body>
<div class="container">
    <div class="icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
    <div class="error-code">500</div>
    <div class="divider"></div>
    <h1>Erreur interne du serveur</h1>
    <p>Une erreur inattendue s'est produite.<br>L'équipe technique a été notifiée. Veuillez réessayer.</p>

    <%-- Détail de l'erreur en mode dev --%>
    <%
        Throwable throwable = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
        if (throwable == null) throwable = exception;
        String errorMsg = (String) request.getAttribute("jakarta.servlet.error.message");
        if (throwable != null) {
    %>
    <div class="error-detail">
        <strong style="color:#ef9a9a">Erreur :</strong>
        <%= throwable.getClass().getName() %><br>
        <%= throwable.getMessage() != null ? throwable.getMessage().replace("<","&lt;") : "Aucun message" %>
    </div>
    <% } else if (errorMsg != null) { %>
    <div class="error-detail"><%= errorMsg %></div>
    <% } %>

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
