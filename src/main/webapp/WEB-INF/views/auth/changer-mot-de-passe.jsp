<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Changement de mot de passe — UCAD Cotisations</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --primary: #0f766e;
            --primary-hover: #115e59;
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
                radial-gradient(at 0% 0%, rgba(15, 118, 110, 0.08) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(30, 58, 138, 0.05) 0px, transparent 50%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
            overflow-y: auto;
            overflow-x: hidden;
            color: var(--text-dark);
        }

        .container {
            width: 100%;
            max-width: 460px;
            margin: auto;
        }

        .logo-header {
            text-align: center;
            margin-bottom: 24px;
        }

        .logo-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            color: #ffffff;
            margin-bottom: 12px;
            box-shadow: 0 10px 25px -5px rgba(15, 118, 110, 0.25);
        }

        .logo-header h1 {
            color: var(--text-dark);
            font-size: 21px;
            font-weight: 700;
        }

        .logo-header p {
            color: var(--text-muted);
            font-size: 13.5px;
            margin-top: 4px;
        }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 20px 25px -5px rgba(0, 0, 0, 0.04);
        }

        .card h2 {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .card .subtitle {
            color: var(--text-muted);
            font-size: 13px;
            margin-bottom: 22px;
            line-height: 1.5;
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

        .form-control:focus {
            outline: none;
            border-color: #0f766e;
            box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.15);
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #0f766e, #0d9488);
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
            box-shadow: 0 4px 12px rgba(15, 118, 110, 0.25);
            margin-top: 10px;
        }

        .btn-submit:hover {
            background: linear-gradient(135deg, #115e59, #0f766e);
            transform: translateY(-1px);
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

        .back-link {
            display: block;
            text-align: center;
            margin-top: 18px;
            color: #64748b;
            font-size: 13px;
            text-decoration: none;
        }

        .back-link:hover {
            color: #0f766e;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="logo-header">
        <div class="logo-icon"><i class="bi bi-shield-lock-fill"></i></div>
        <h1>UCAD Cotisations</h1>
        <p>Sécurisation & Personnalisation du compte</p>
    </div>

    <div class="card">
        <h2>Définir mon mot de passe</h2>
        <p class="subtitle">Veuillez saisir votre adresse e-mail, le mot de passe initial communiqué par l'administrateur, puis définir votre nouveau mot de passe.</p>

        <% 
            String error = (String) request.getAttribute("error");
            String email = (String) request.getAttribute("email");
        %>

        <% if (error != null) { %>
        <div class="alert-error"><i class="bi bi-exclamation-circle-fill"></i> <%= error %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/changer-mot-de-passe">
            <div class="form-group">
                <label class="form-label" for="email">Adresse e-mail</label>
                <div class="input-wrapper">
                    <i class="bi bi-envelope-fill input-icon"></i>
                    <input type="email" id="email" name="email" class="form-control"
                           required placeholder="votre.email@ucad.sn"
                           value="<%= email != null ? email : "" %>">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="ancienPassword">Mot de passe actuel (reçu de l'admin)</label>
                <div class="input-wrapper">
                    <i class="bi bi-key-fill input-icon"></i>
                    <input type="password" id="ancienPassword" name="ancienPassword"
                           class="form-control" required placeholder="Mot de passe temporaire">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="nouveauPassword">Nouveau mot de passe</label>
                <div class="input-wrapper">
                    <i class="bi bi-lock-fill input-icon"></i>
                    <input type="password" id="nouveauPassword" name="nouveauPassword"
                           class="form-control" required minlength="6" placeholder="Minimum 6 caractères">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirmer le nouveau mot de passe</label>
                <div class="input-wrapper">
                    <i class="bi bi-shield-check input-icon"></i>
                    <input type="password" id="confirmPassword" name="confirmPassword"
                           class="form-control" required minlength="6" placeholder="Confirmez le nouveau mot de passe">
                </div>
            </div>

            <button type="submit" class="btn-submit">
                <i class="bi bi-check-circle-fill"></i> Valider mon nouveau mot de passe
            </button>
        </form>

        <a href="<%= request.getContextPath() %>/login" class="back-link">
            <i class="bi bi-arrow-left"></i> Retour à la page de connexion
        </a>
    </div>
</div>

</body>
</html>
