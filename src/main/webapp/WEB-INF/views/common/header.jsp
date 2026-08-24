<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    sn.ucad.cotisations.model.Utilisateur currentUser =
        (sn.ucad.cotisations.model.Utilisateur) session.getAttribute("sessionUser");
    sn.ucad.cotisations.model.Membre currentMembre =
        (sn.ucad.cotisations.model.Membre) session.getAttribute("sessionMembre");
    String currentRole = (String) session.getAttribute("sessionRole");
    boolean isAdmin = "ADMIN".equals(currentRole);
    String ctx = request.getContextPath();
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    String displayName = (currentMembre != null) ? currentMembre.getNomComplet() : (currentUser != null ? currentUser.getEmail() : "");
    String initials = "U";
    if (currentMembre != null && currentMembre.getPrenom() != null && !currentMembre.getPrenom().isBlank()) {
        initials = currentMembre.getPrenom().substring(0,1).toUpperCase();
    } else if (currentUser != null && currentUser.getEmail() != null) {
        initials = currentUser.getEmail().substring(0,1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="fr" data-theme="<%= isAdmin ? "admin" : "membre" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle != null ? pageTitle : 'UCAD Cotisations'}"/></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-body:     #f8fafc;
            --card-bg:     #ffffff;
            --text-main:   #0f172a;
            --text-muted:  #64748b;
            --border-ui:   #e2e8f0;
            --border-hover:#cbd5e1;
            --success-bg:  #ecfdf5;
            --success-txt: #065f46;
            --danger-bg:   #fef2f2;
            --danger-txt:  #991b1b;
            --warning-bg:  #fffbeb;
            --warning-txt: #92400e;
            --info-bg:     #eff6ff;
            --info-txt:    #1e40af;
            --sidebar-collapsed-w: 68px;
            --sidebar-expanded-w:  260px;
        }

        /* THÈME ADMIN */
        html[data-theme="admin"] {
            --brand-primary:      #1e3a8a;
            --brand-primary-lt:   #2563eb;
            --brand-accent:       #f59e0b;
            --sidebar-bg:         #0f172a;
            --sidebar-header:     #1e293b;
            --sidebar-text:       #94a3b8;
            --sidebar-text-active:#ffffff;
            --sidebar-active-bg:  #1e293b;
            --sidebar-accent-bar: #3b82f6;
            --role-badge-bg:      #dbeafe;
            --role-badge-txt:     #1e40af;
        }

        /* THÈME MEMBRE */
        html[data-theme="membre"] {
            --brand-primary:      #0f766e;
            --brand-primary-lt:   #0d9488;
            --brand-accent:       #14b8a6;
            --sidebar-bg:         #134e4a;
            --sidebar-header:     #115e59;
            --sidebar-text:       #99f6e4;
            --sidebar-text-active:#ffffff;
            --sidebar-active-bg:  #115e59;
            --sidebar-accent-bar: #2dd4bf;
            --role-badge-bg:      #ccfbf1;
            --role-badge-txt:     #115e59;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
        }

        /* ==============================================================
           SIDEBAR ADMIN : AUTO-EXPANSION FLUIDE AU SURVOL (SANS CLIC)
        ============================================================== */
        .sidebar {
            width: var(--sidebar-collapsed-w);
            min-height: 100vh;
            background: var(--sidebar-bg);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 200;
            box-shadow: 2px 0 10px rgba(0,0,0,0.06);
            transition: width 0.25s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.25s ease;
            overflow-x: hidden;
            overflow-y: auto;
        }

        /* État par défaut (compact 68px) */
        .sidebar:not(:hover) .brand-text,
        .sidebar:not(:hover) .sidebar-user-info,
        .sidebar:not(:hover) .nav-section,
        .sidebar:not(:hover) .nav-label,
        .sidebar:not(:hover) .footer-label {
            display: none !important;
        }

        .sidebar:not(:hover) .nav-item a {
            justify-content: center;
            padding: 12px 0;
        }

        .sidebar:not(:hover) .sidebar-user {
            justify-content: center;
            padding: 10px;
            margin: 12px 8px 4px;
        }

        .sidebar:not(:hover) .sidebar-footer a {
            justify-content: center;
        }

        .sidebar:not(:hover) .sidebar-brand {
            justify-content: center;
            padding: 18px 0;
        }

        /* Au simple SURVOL DE LA SOURIS : la barre s'ouvre directement à 260px */
        .sidebar:hover {
            width: var(--sidebar-expanded-w);
            box-shadow: 6px 0 28px rgba(0,0,0,0.35);
        }

        .sidebar:hover .brand-text {
            display: block !important;
        }

        .sidebar:hover .sidebar-user-info {
            display: block !important;
        }

        .sidebar:hover .nav-section {
            display: block !important;
        }

        .sidebar:hover .nav-label {
            display: inline !important;
        }

        .sidebar:hover .footer-label {
            display: inline !important;
        }

        .sidebar:hover .nav-item a {
            justify-content: flex-start;
            padding: 11px 20px;
        }

        .sidebar:hover .sidebar-user {
            justify-content: flex-start;
            padding: 12px 14px;
            margin: 12px 10px 4px;
        }

        .sidebar:hover .sidebar-footer a {
            justify-content: flex-start;
            padding: 0;
        }

        .sidebar:hover .sidebar-brand {
            justify-content: flex-start;
            padding: 18px 18px;
        }

        /* Entête de la sidebar */
        .sidebar-brand {
            background: var(--sidebar-header);
            border-bottom: 1px solid rgba(255,255,255,0.08);
            min-height: 64px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: padding 0.2s ease;
        }

        .sidebar-brand .brand-text {
            overflow: hidden;
            white-space: nowrap;
        }

        .sidebar-brand h1 {
            color: #ffffff;
            font-size: 14px;
            font-weight: 700;
            line-height: 1.2;
            margin: 0;
        }

        .sidebar-brand span {
            color: rgba(255,255,255,0.6);
            font-size: 11px;
            font-weight: 400;
            display: block;
            margin-top: 1px;
        }

        /* Zone Profil Utilisateur dans Sidebar */
        .sidebar-user {
            background: rgba(255,255,255,0.06);
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.08);
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.2s ease;
        }

        .sidebar-user:hover {
            background: rgba(255,255,255,0.12);
            border-color: rgba(255,255,255,0.2);
            transform: translateY(-1px);
        }

        .sidebar-user .avatar {
            width: 36px;
            height: 36px;
            background: var(--brand-primary-lt);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 13.5px;
            flex-shrink: 0;
        }

        .sidebar-user-info { color: #ffffff; overflow: hidden; flex: 1; }
        .sidebar-user-info .name {
            font-size: 12.5px;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .sidebar-user-info .role-tag {
            font-size: 10.5px;
            display: inline-block;
            padding: 1px 7px;
            border-radius: 12px;
            background: rgba(255,255,255,0.15);
            margin-top: 3px;
            font-weight: 500;
            white-space: nowrap;
        }

        .sidebar-nav { flex: 1; padding: 8px 0; overflow-y: auto; }
        .nav-section {
            padding: 10px 20px 4px;
            color: rgba(255,255,255,0.4);
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            white-space: nowrap;
            overflow: hidden;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 20px;
            color: var(--sidebar-text);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 500;
            transition: all 0.2s ease;
            white-space: nowrap;
            overflow: hidden;
        }

        .nav-item a:hover {
            background: rgba(255,255,255,0.05);
            color: #ffffff;
        }

        .nav-item a.active {
            background: var(--sidebar-active-bg);
            color: var(--sidebar-text-active);
            font-weight: 600;
            border-right: 4px solid var(--sidebar-accent-bar);
        }

        .nav-item a .bi { font-size: 17px; flex-shrink: 0; }

        .sidebar-footer {
            padding: 14px 18px;
            border-top: 1px solid rgba(255,255,255,0.08);
        }

        .sidebar-footer a {
            display: flex;
            align-items: center;
            gap: 10px;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            font-size: 13px;
            transition: color 0.2s;
            white-space: nowrap;
            overflow: hidden;
        }

        .sidebar-footer a:hover { color: #ffffff; }

        /* =============================================
           LAYOUT PRINCIPAL ADMIN (marge 68px)
        ============================================= */
        .main-content {
            margin-left: var(--sidebar-collapsed-w);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background: var(--bg-body);
            transition: margin-left 0.25s ease;
        }

        /* =============================================
           TOPBAR ADMIN
        ============================================= */
        .topbar {
            background: #ffffff;
            padding: 0 28px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--border-ui);
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .topbar-title {
            font-size: 17px;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .topbar-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .badge-role-top {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            background: var(--role-badge-bg);
            color: var(--role-badge-txt);
        }

        /* =============================================
           NAV HORIZONTALE MEMBRE
        ============================================= */
        html[data-theme="membre"] body {
            flex-direction: column;
        }

        html[data-theme="membre"] .sidebar { display: none; }

        html[data-theme="membre"] .main-content {
            margin-left: 0;
        }

        html[data-theme="membre"] .topbar {
            height: auto;
            flex-direction: column;
            padding: 0;
            align-items: stretch;
        }

        .membre-topbar-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            height: 64px;
            background: var(--sidebar-header);
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .membre-brand {
            color: #ffffff;
            font-size: 15px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .membre-brand-sub {
            font-size: 11px;
            font-weight: 400;
            color: rgba(255,255,255,0.6);
        }

        .membre-user-area {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .membre-user-btn {
            display: flex;
            align-items: center;
            gap: 9px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.15);
            padding: 6px 14px;
            border-radius: 24px;
            color: #ffffff;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .membre-user-btn:hover {
            background: rgba(255,255,255,0.2);
            border-color: rgba(255,255,255,0.3);
            transform: translateY(-1px);
        }

        .membre-user-btn .m-avatar {
            width: 26px;
            height: 26px;
            background: var(--brand-accent);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            color: #0f172a;
        }

        .membre-nav-bar {
            display: flex;
            align-items: center;
            background: var(--sidebar-bg);
            padding: 0 16px;
            gap: 4px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }

        .membre-nav-bar a {
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 13px 16px;
            color: var(--sidebar-text);
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            border-bottom: 3px solid transparent;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .membre-nav-bar a:hover {
            color: #ffffff;
            background: rgba(255,255,255,0.05);
        }

        .membre-nav-bar a.active {
            color: #ffffff;
            border-bottom-color: var(--sidebar-accent-bar);
            background: rgba(255,255,255,0.05);
        }

        .membre-nav-bar .logout-link {
            margin-left: auto;
            color: rgba(255,255,255,0.6);
            font-size: 12.5px;
        }

        .membre-nav-bar .logout-link:hover {
            color: #ffffff;
        }

        html[data-theme="membre"] .topbar-title {
            display: none;
        }

        /* =============================================
           PAGE BODY
        ============================================= */
        .page-body {
            flex: 1;
            padding: 24px 28px;
            max-width: 1300px;
            width: 100%;
            margin: 0 auto;
        }

        /* Cards */
        .card {
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid var(--border-ui);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.02);
            margin-bottom: 24px;
        }

        .card-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-ui);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #ffffff;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
        }

        .card-header h5 {
            font-size: 14.5px;
            font-weight: 700;
            color: var(--text-main);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .card-body { padding: 20px; }

        /* KPI */
        .kpi-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid var(--border-ui);
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        }

        .kpi-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }

        .kpi-info .value {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-main);
            line-height: 1.1;
        }

        .kpi-info .label {
            font-size: 12.5px;
            color: var(--text-muted);
            margin-top: 4px;
            font-weight: 500;
        }

        /* Tables */
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            background: #f8fafc;
            color: #475569;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.3px;
            text-transform: uppercase;
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-ui);
            white-space: nowrap;
        }

        tbody td {
            padding: 13px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13.5px;
            color: var(--text-main);
            vertical-align: middle;
        }

        tbody tr:hover { background: #f8fafc; }
        tbody tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }

        .badge-success { background: var(--success-bg); color: var(--success-txt); border: 1px solid #a7f3d0; }
        .badge-warning { background: var(--warning-bg); color: var(--warning-txt); border: 1px solid #fde68a; }
        .badge-danger  { background: var(--danger-bg);  color: var(--danger-txt);  border: 1px solid #fecaca; }
        .badge-info    { background: var(--info-bg);    color: var(--info-txt);    border: 1px solid #bfdbfe; }
        .badge-muted   { background: #f1f5f9;           color: #64748b;           border: 1px solid #e2e8f0; }

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            text-decoration: none;
            transition: all 0.2s ease;
            font-family: inherit;
        }

        .btn-primary { background: var(--brand-primary); color: white; }
        .btn-primary:hover { background: var(--brand-primary-lt); transform: translateY(-1px); }
        .btn-accent { background: #d97706; color: white; }
        .btn-accent:hover { background: #b45309; }
        .btn-success { background: #059669; color: white; }
        .btn-success:hover { background: #047857; }
        .btn-outline { background: #ffffff; color: #334155; border: 1px solid var(--border-ui); }
        .btn-outline:hover { background: #f8fafc; border-color: var(--border-hover); color: var(--text-main); }
        .btn-sm { padding: 6px 12px; font-size: 12px; border-radius: 6px; }
        .btn-danger { background: #dc2626; color: white; }
        .btn-danger:hover { background: #b91c1c; }

        /* Alerts */
        .alert {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 13.5px;
        }

        .alert-success { background: var(--success-bg); color: var(--success-txt); border: 1px solid #a7f3d0; }
        .alert-danger  { background: var(--danger-bg);  color: var(--danger-txt);  border: 1px solid #fecaca; }
        .alert-warning { background: var(--warning-bg); color: var(--warning-txt); border: 1px solid #fde68a; }

        /* Forms */
        .form-group { margin-bottom: 16px; }
        .form-label { display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .form-control {
            width: 100%;
            padding: 9px 13px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            font-family: inherit;
            color: var(--text-main);
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--brand-primary-lt);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        /* Grid */
        .grid { display: grid; gap: 18px; }
        .grid-4 { grid-template-columns: repeat(4, 1fr); }
        .grid-3 { grid-template-columns: repeat(3, 1fr); }
        .grid-2 { grid-template-columns: repeat(2, 1fr); }

        /* Utilities */
        .d-flex { display: flex; }
        .align-items-center { align-items: center; }
        .justify-content-between { justify-content: space-between; }
        .gap-2 { gap: 8px; }
        .gap-3 { gap: 12px; }
        .mb-4 { margin-bottom: 20px; }
        .mb-3 { margin-bottom: 12px; }
        .mt-3 { margin-top: 12px; }
        .text-muted { color: var(--text-muted); font-size: 13px; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }

        @media (max-width: 1024px) {
            .grid-4 { grid-template-columns: repeat(2, 1fr); }
            .grid-3 { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 768px) {
            html[data-theme="admin"] .sidebar { transform: translateX(-100%); }
            html[data-theme="admin"] .main-content { margin-left: 0; }
            .grid-4, .grid-3, .grid-2 { grid-template-columns: 1fr; }
            .membre-nav-bar { overflow-x: auto; }
        }
    </style>
</head>
<body>

<% if (isAdmin) { %>
<!-- =========== SIDEBAR ADMIN (Auto-expansion directe au survol) =========== -->
<nav class="sidebar" id="adminSidebar">
    <div class="sidebar-brand">
        <i class="bi bi-mortarboard-fill" style="color:#f59e0b;flex-shrink:0;font-size:22px"></i>
        <div class="brand-text">
            <h1>UCAD Cotisations</h1>
            <span>Espace Administration</span>
        </div>
    </div>

    <% if (currentUser != null) { %>
    <!-- Cliquer sur le profil => redirection directe vers /profil -->
    <a href="<%= ctx %>/profil" class="sidebar-user" title="Accéder à mon profil">
        <div class="avatar"><%= initials %></div>
        <div class="sidebar-user-info">
            <div class="name"><%= displayName %></div>
            <span class="role-tag">🛡️ Administrateur</span>
        </div>
    </a>
    <% } %>

    <div class="sidebar-nav">
        <div class="nav-section">Navigation</div>

        <div class="nav-item">
            <a href="<%= ctx %>/dashboard" class="<%= "dashboard".equals(activePage) ? "active" : "" %>" title="Tableau de bord">
                <i class="bi bi-grid-1x2-fill"></i>
                <span class="nav-label">Tableau de bord</span>
            </a>
        </div>
        <div class="nav-item">
            <a href="<%= ctx %>/membres" class="<%= "membres".equals(activePage) ? "active" : "" %>" title="Membres">
                <i class="bi bi-people-fill"></i>
                <span class="nav-label">Membres</span>
            </a>
        </div>
        <div class="nav-item">
            <a href="<%= ctx %>/cotisations" class="<%= "cotisations".equals(activePage) ? "active" : "" %>" title="Cotisations">
                <i class="bi bi-cash-stack"></i>
                <span class="nav-label">Cotisations</span>
            </a>
        </div>
        <div class="nav-item">
            <a href="<%= ctx %>/amendes" class="<%= "amendes".equals(activePage) ? "active" : "" %>" title="Amendes">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <span class="nav-label">Amendes</span>
            </a>
        </div>
    </div>

    <div class="sidebar-footer">
        <a href="<%= ctx %>/logout" title="Déconnexion">
            <i class="bi bi-box-arrow-left"></i>
            <span class="footer-label">Déconnexion</span>
        </a>
    </div>
</nav>

<div class="main-content" id="mainContent">
    <header class="topbar">
        <div class="topbar-title">
            <c:out value="${pageTitle != null ? pageTitle : 'UCAD Cotisations'}"/>
        </div>
        <div class="topbar-actions">
            <span class="badge-role-top">🛡️ Mode Administrateur</span>
            <span class="text-muted" style="font-size:12px">
                <i class="bi bi-clock"></i>
                <%= new java.text.SimpleDateFormat("EEE d MMM yyyy", new java.util.Locale("fr")).format(new java.util.Date()) %>
            </span>
        </div>
    </header>
    <div class="page-body">

<% } else { %>
<!-- =========== NAV HORIZONTALE MEMBRE =========== -->
<div class="main-content">
    <header class="topbar">
        <!-- Ligne supérieure : logo + user cliquable pour profil -->
        <div class="membre-topbar-top">
            <div>
                <div class="membre-brand">
                    <i class="bi bi-mortarboard-fill" style="color:#2dd4bf"></i>
                    UCAD Cotisations
                </div>
                <div class="membre-brand-sub">Espace Adhérent</div>
            </div>
            <div class="membre-user-area">
                <a href="<%= ctx %>/profil" class="membre-user-btn" title="Accéder à mon profil">
                    <div class="m-avatar"><%= initials %></div>
                    <span><%= displayName %></span>
                    <i class="bi bi-gear-fill" style="font-size:12px;opacity:.7"></i>
                </a>
            </div>
        </div>
        <!-- Barre de navigation horizontale -->
        <nav class="membre-nav-bar">
            <a href="<%= ctx %>/cotisations" class="<%= "cotisations".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-cash-stack"></i> Mes Cotisations
            </a>
            <a href="<%= ctx %>/amendes" class="<%= "amendes".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-exclamation-triangle-fill"></i> Mes Amendes
            </a>
            <a href="<%= ctx %>/logout" class="logout-link">
                <i class="bi bi-box-arrow-right"></i> Déconnexion
            </a>
        </nav>
    </header>
    <div class="page-body">
<% } %>

        <%-- Messages flash --%>
        <% 
           String successMsg = (String) session.getAttribute("successMsg");
           String errorMsg   = (String) session.getAttribute("errorMsg");
           if (successMsg != null) { session.removeAttribute("successMsg"); %>
        <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> <%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { session.removeAttribute("errorMsg"); %>
        <div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> <%= errorMsg %></div>
        <% } %>
