<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion — UCAD Cotisations</title>
    <meta name="description" content="Connectez-vous à l'application de gestion des cotisations UCAD">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --primary:  #1a237e;
            --accent:   #f57f17;
            --bg:       #0d1117;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        /* Animated background */
        body::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse at 20% 50%, rgba(26,35,126,0.4) 0%, transparent 60%),
                        radial-gradient(ellipse at 80% 20%, rgba(245,127,23,0.2) 0%, transparent 50%);
        }
        .floating-shapes { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }
        .shape {
            position: absolute; border-radius: 50%;
            background: rgba(26,35,126,0.1); border: 1px solid rgba(26,35,126,0.2);
            animation: float 8s ease-in-out infinite;
        }
        .shape:nth-child(1) { width: 300px; height: 300px; top: -100px; right: -100px; animation-delay: 0s; }
        .shape:nth-child(2) { width: 200px; height: 200px; bottom: -50px; left: -50px; animation-delay: 3s; }
        .shape:nth-child(3) { width: 150px; height: 150px; top: 60%; right: 10%; animation-delay: 1.5s; }
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(5deg); }
        }

        .login-container {
            position: relative; z-index: 10;
            width: 420px; max-width: 95vw;
        }
        .login-logo {
            text-align: center; margin-bottom: 32px;
        }
        .logo-icon {
            width: 72px; height: 72px; background: linear-gradient(135deg, var(--primary), #3f51b5);
            border-radius: 20px; display: inline-flex; align-items: center; justify-content: center;
            font-size: 30px; color: white; margin-bottom: 16px;
            box-shadow: 0 8px 32px rgba(26,35,126,0.4);
        }
        .login-logo h1 { color: white; font-size: 22px; font-weight: 700; }
        .login-logo p  { color: rgba(255,255,255,0.5); font-size: 13px; margin-top: 4px; }

        .login-card {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 36px;
            box-shadow: 0 24px 64px rgba(0,0,0,0.4);
        }
        .login-card h2 { color: white; font-size: 18px; font-weight: 600; margin-bottom: 6px; }
        .login-card .subtitle { color: rgba(255,255,255,0.5); font-size: 13px; margin-bottom: 28px; }

        .form-group { margin-bottom: 20px; }
        .form-label { display: block; color: rgba(255,255,255,0.8); font-size: 12.5px; font-weight: 500; margin-bottom: 8px; }
        .input-wrapper { position: relative; }
        .input-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: rgba(255,255,255,0.3); font-size: 15px; }
        .form-control {
            width: 100%; padding: 12px 14px 12px 42px;
            background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px; color: white; font-size: 14px; font-family: inherit;
            transition: all 0.2s;
        }
        .form-control::placeholder { color: rgba(255,255,255,0.25); }
        .form-control:focus { outline: none; border-color: rgba(245,127,23,0.6); background: rgba(255,255,255,0.1); box-shadow: 0 0 0 3px rgba(245,127,23,0.15); }

        .btn-login {
            width: 100%; padding: 13px; border: none; border-radius: 10px;
            background: linear-gradient(135deg, var(--accent), #ff8f00);
            color: white; font-size: 14px; font-weight: 600; cursor: pointer;
            font-family: inherit; display: flex; align-items: center; justify-content: center; gap: 8px;
            transition: all 0.2s; box-shadow: 0 4px 16px rgba(245,127,23,0.35);
        }
        .btn-login:hover { transform: translateY(-1px); box-shadow: 0 6px 24px rgba(245,127,23,0.5); }
        .btn-login:active { transform: translateY(0); }

        .alert-error {
            background: rgba(198,40,40,0.2); border: 1px solid rgba(198,40,40,0.4);
            color: #ff8a80; padding: 12px 16px; border-radius: 10px; font-size: 13px;
            display: flex; align-items: center; gap: 10px; margin-bottom: 20px;
        }

        .demo-info {
            margin-top: 24px; padding: 14px; background: rgba(26,35,126,0.3);
            border: 1px solid rgba(26,35,126,0.5); border-radius: 10px;
        }
        .demo-info p { color: rgba(255,255,255,0.6); font-size: 12px; margin-bottom: 6px; }
        .demo-info code { color: var(--accent); font-size: 12px; background: rgba(245,127,23,0.1); padding: 2px 6px; border-radius: 4px; }
    </style>
</head>
<body>
<div class="floating-shapes">
    <div class="shape"></div>
    <div class="shape"></div>
    <div class="shape"></div>
</div>

<div class="login-container">
    <div class="login-logo">
        <div class="logo-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <h1>UCAD Cotisations</h1>
        <p>Système de gestion des cotisations et amendes</p>
    </div>

    <div class="login-card">
        <h2>Connexion</h2>
        <p class="subtitle">Entrez vos identifiants pour accéder à votre espace</p>

        <% String error = (String) request.getAttribute("error");
           String logoutMsg = "deconnecte".equals(request.getParameter("msg")) ? "Vous avez été déconnecté." : null;
           String emailSaisi = (String) request.getAttribute("emailSaisi");
        %>
        <% if (error != null) { %>
        <div class="alert-error"><i class="bi bi-exclamation-circle-fill"></i> <%= error %></div>
        <% } %>
        <% if (logoutMsg != null) { %>
        <div style="background:rgba(46,125,50,0.2);border:1px solid rgba(46,125,50,0.4);color:#a5d6a7;padding:12px 16px;border-radius:10px;font-size:13px;display:flex;align-items:center;gap:10px;margin-bottom:20px">
            <i class="bi bi-check-circle-fill"></i> <%= logoutMsg %>
        </div>
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
                    <input type="password" id="password" name="password" class="form-control"
                           placeholder="••••••••" required autocomplete="current-password">
                </div>
            </div>
            <button type="submit" class="btn-login">
                <i class="bi bi-box-arrow-in-right"></i> Se connecter
            </button>
        </form>

        <div class="demo-info">
            <p><strong style="color:rgba(255,255,255,0.7)">Compte admin par défaut :</strong></p>
            <p>Email : <code>admin@ucad.sn</code></p>
            <p>Mot de passe : <code>admin123</code></p>
        </div>
    </div>
</div>
</body>
</html>
