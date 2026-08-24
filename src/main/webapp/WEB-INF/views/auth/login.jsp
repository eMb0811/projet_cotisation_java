<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion — UCAD Cotisations</title>
    <meta name="description" content="Connectez-vous à l'application de gestion des cotisations UCAD">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --primary: #1e3a8a;
            --primary-hover: #1e40af;
            --accent: #f59e0b;
            --bg-page: #f8fafc;
            --card-bg: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
        }

        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-page);
            background-image: 
                radial-gradient(at 0% 0%, rgba(30, 58, 138, 0.06) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(245, 158, 11, 0.05) 0px, transparent 50%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
            overflow-y: auto;
            overflow-x: hidden;
            color: var(--text-dark);
        }

        .login-container {
            width: 100%;
            max-width: 440px;
            margin: auto;
        }

        .login-logo {
            text-align: center;
            margin-bottom: 28px;
        }

        .logo-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, #1e3a8a, #3b82f6);
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            color: #ffffff;
            margin-bottom: 12px;
            box-shadow: 0 10px 25px -5px rgba(30, 58, 138, 0.25);
        }

        .login-logo h1 {
            color: var(--text-dark);
            font-size: 22px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .login-logo p {
            color: var(--text-muted);
            font-size: 13.5px;
            margin-top: 4px;
        }

        .login-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 36px 32px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 20px 25px -5px rgba(0, 0, 0, 0.04);
        }

        .login-card h2 {
            color: var(--text-dark);
            font-size: 19px;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .login-card .subtitle {
            color: var(--text-muted);
            font-size: 13.5px;
            margin-bottom: 24px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-label {
            display: block;
            color: #334155;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 7px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 16px;
        }

        .form-control {
            width: 100%;
            padding: 12px 14px 12px 42px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            color: var(--text-dark);
            font-size: 14px;
            font-family: inherit;
            transition: all 0.2s ease;
        }

        .form-control::placeholder {
            color: #94a3b8;
        }

        .form-control:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #1e3a8a, #2563eb);
            color: white;
            font-size: 14.5px;
            font-weight: 600;
            cursor: pointer;
            font-family: inherit;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
            margin-top: 8px;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #1e40af, #1d4ed8);
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.35);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .alert-success {
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #065f46;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .demo-info {
            margin-top: 24px;
            padding: 14px 16px;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
        }

        .demo-info p {
            color: #475569;
            font-size: 12.5px;
            margin-bottom: 4px;
        }

        .demo-info code {
            color: #1e3a8a;
            font-weight: 600;
            font-size: 12.5px;
            background: #e2e8f0;
            padding: 2px 6px;
            border-radius: 4px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-logo">
        <div class="logo-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <h1>UCAD Cotisations</h1>
        <p>Système de gestion des cotisations et amendes</p>
    </div>

    <div class="login-card">
        <h2>Connexion</h2>
        <p class="subtitle">Entrez vos identifiants pour accéder à votre espace</p>

        <% 
            String error = (String) request.getAttribute("error");
            String successMsg = (String) session.getAttribute("successMsg");
            if (successMsg != null) { session.removeAttribute("successMsg"); }
            String logoutMsg = "deconnecte".equals(request.getParameter("msg")) ? "Vous avez été déconnecté avec succès." : null;
            String emailSaisi = (String) request.getAttribute("emailSaisi");
        %>

        <% if (error != null) { %>
        <div class="alert-error"><i class="bi bi-exclamation-circle-fill"></i> <%= error %></div>
        <% } %>

        <% if (successMsg != null) { %>
        <div class="alert-success"><i class="bi bi-check-circle-fill"></i> <%= successMsg %></div>
        <% } %>

        <% if (logoutMsg != null) { %>
        <div class="alert-success"><i class="bi bi-check-circle-fill"></i> <%= logoutMsg %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
            <div class="form-group">
                <label class="form-label" for="email">Adresse e-mail</label>
                <div class="input-wrapper">
                    <i class="bi bi-envelope-fill input-icon"></i>
                    <input type="email" id="email" name="email" class="form-control"
                           placeholder="votre@email.ucad.sn" required autocomplete="email"
                           value="<%= emailSaisi != null ? emailSaisi : "" %>">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Mot de passe</label>
                <div class="input-wrapper">
                    <i class="bi bi-lock-fill input-icon"></i>
                    <input type="password" id="password" name="password"
                           class="form-control" placeholder="••••••••" required
                           autocomplete="current-password">
                </div>
            </div>
            <button type="submit" class="btn-login">
                <i class="bi bi-box-arrow-in-right"></i> Se connecter
            </button>
        </form>

        <div style="margin-top:18px;text-align:center;">
            <a href="<%= request.getContextPath() %>/changer-mot-de-passe" style="font-size:13px;color:#2563eb;text-decoration:none;font-weight:500;">
                <i class="bi bi-key-fill"></i> Première connexion ? Changer de mot de passe
            </a>
        </div>

        <div class="demo-info">
            <p><strong style="color:#1e293b">Compte admin par défaut :</strong></p>
            <p>Email : <code>admin@ucad.sn</code> &nbsp;|&nbsp; Mot de passe : <code>admin123</code></p>
        </div>
    </div>
</div>

</body>
</html>