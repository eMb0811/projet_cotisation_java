<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    sn.ucad.cotisations.model.Utilisateur currentUser =
        (sn.ucad.cotisations.model.Utilisateur) session.getAttribute("sessionUser");
    String currentRole = (String) session.getAttribute("sessionRole");
    String ctx = request.getContextPath();
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
%>
<!DOCTYPE html>
<html lang="fr">
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
            --primary:     #1a237e;
            --primary-lt:  #283593;
            --accent:      #f57f17;
            --accent-lt:   #ffa000;
            --success:     #2e7d32;
            --danger:      #c62828;
            --sidebar-w:   260px;
            --bg:          #f0f2f5;
            --card-bg:     #ffffff;
            --text:        #212121;
            --text-muted:  #757575;
            --border:      #e0e0e0;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); display: flex; min-height: 100vh; }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-w); min-height: 100vh; background: var(--primary);
            display: flex; flex-direction: column; position: fixed; top: 0; left: 0; z-index: 100;
            box-shadow: 4px 0 20px rgba(0,0,0,0.15);
        }
        .sidebar-brand {
            padding: 24px 20px 16px; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .sidebar-brand h1 { color: white; font-size: 15px; font-weight: 700; line-height: 1.3; }
        .sidebar-brand span { color: var(--accent-lt); font-size: 11px; font-weight: 400; display: block; }

        .sidebar-user {
            padding: 16px 20px; background: rgba(0,0,0,0.15); margin: 12px; border-radius: 10px;
        }
        .sidebar-user .avatar {
            width: 38px; height: 38px; background: var(--accent); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white; font-weight: 700; font-size: 14px; margin-right: 10px; flex-shrink: 0;
        }
        .sidebar-user-info { color: rgba(255,255,255,0.9); }
        .sidebar-user-info .name { font-size: 13px; font-weight: 600; }
        .sidebar-user-info .role { font-size: 11px; color: rgba(255,255,255,0.5); }

        .sidebar-nav { flex: 1; padding: 8px 0; overflow-y: auto; }
        .nav-section { padding: 12px 20px 4px; color: rgba(255,255,255,0.35); font-size: 10px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; }
        .nav-item a {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 20px; color: rgba(255,255,255,0.7); text-decoration: none;
            font-size: 13.5px; font-weight: 500; transition: all 0.2s;
        }
        .nav-item a:hover, .nav-item a.active {
            background: rgba(255,255,255,0.12); color: white;
            border-right: 3px solid var(--accent-lt);
        }
        .nav-item a .bi { font-size: 16px; }
        .badge-nav {
            margin-left: auto; background: var(--accent); color: white;
            font-size: 10px; padding: 2px 7px; border-radius: 10px; font-weight: 600;
        }

        .sidebar-footer { padding: 16px 20px; border-top: 1px solid rgba(255,255,255,0.1); }
        .sidebar-footer a {
            display: flex; align-items: center; gap: 10px;
            color: rgba(255,255,255,0.6); text-decoration: none; font-size: 13px;
            transition: color 0.2s;
        }
        .sidebar-footer a:hover { color: white; }

        /* Main content */
        .main-content { margin-left: var(--sidebar-w); flex: 1; display: flex; flex-direction: column; min-height: 100vh; }

        /* Top bar */
        .topbar {
            background: white; padding: 0 28px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid var(--border); position: sticky; top: 0; z-index: 50;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .topbar-title { font-size: 18px; font-weight: 700; color: var(--primary); }
        .topbar-actions { display: flex; align-items: center; gap: 12px; }

        /* Page body */
        .page-body { flex: 1; padding: 28px; }

        /* Cards */
        .card {
            background: var(--card-bg); border-radius: 12px; border: 1px solid var(--border);
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .card-header { padding: 18px 22px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
        .card-header h5 { font-size: 15px; font-weight: 600; color: var(--primary); margin: 0; }
        .card-body { padding: 22px; }

        /* KPI cards */
        .kpi-card {
            background: white; border-radius: 14px; padding: 22px; border: 1px solid var(--border);
            display: flex; align-items: center; gap: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.1); }
        .kpi-icon {
            width: 54px; height: 54px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0;
        }
        .kpi-info .value { font-size: 26px; font-weight: 700; color: var(--text); line-height: 1; }
        .kpi-info .label { font-size: 12px; color: var(--text-muted); margin-top: 4px; font-weight: 500; }

        /* Tables */
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        thead th { background: #f8f9ff; color: var(--primary); font-size: 12px; font-weight: 600; letter-spacing: 0.5px; text-transform: uppercase; padding: 12px 16px; border-bottom: 2px solid var(--border); white-space: nowrap; }
        tbody td { padding: 13px 16px; border-bottom: 1px solid #f0f0f0; font-size: 13.5px; color: var(--text); vertical-align: middle; }
        tbody tr:hover { background: #fafbff; }
        tbody tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge { display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; white-space: nowrap; }
        .badge-success { background: #e8f5e9; color: #2e7d32; }
        .badge-warning { background: #fff3e0; color: #e65100; }
        .badge-danger  { background: #ffebee; color: #c62828; }
        .badge-info    { background: #e3f2fd; color: #1565c0; }
        .badge-muted   { background: #f5f5f5; color: #757575; }

        /* Buttons */
        .btn { display: inline-flex; align-items: center; gap: 7px; padding: 9px 18px; border-radius: 8px; font-size: 13px; font-weight: 500; cursor: pointer; border: none; text-decoration: none; transition: all 0.2s; }
        .btn-primary { background: var(--primary); color: white; }
        .btn-primary:hover { background: var(--primary-lt); }
        .btn-accent  { background: var(--accent); color: white; }
        .btn-accent:hover { background: var(--accent-lt); }
        .btn-success { background: var(--success); color: white; }
        .btn-outline { background: transparent; color: var(--primary); border: 1px solid var(--primary); }
        .btn-outline:hover { background: var(--primary); color: white; }
        .btn-sm { padding: 6px 12px; font-size: 12px; border-radius: 6px; }
        .btn-danger { background: var(--danger); color: white; }

        /* Alerts */
        .alert { display: flex; align-items: flex-start; gap: 12px; padding: 14px 18px; border-radius: 10px; margin-bottom: 20px; font-size: 13.5px; }
        .alert-success { background: #e8f5e9; color: #1b5e20; border-left: 4px solid #2e7d32; }
        .alert-danger  { background: #ffebee; color: #7f0000; border-left: 4px solid #c62828; }
        .alert-warning { background: #fff8e1; color: #e65100; border-left: 4px solid #f57f17; }

        /* Forms */
        .form-group { margin-bottom: 18px; }
        .form-label { display: block; font-size: 13px; font-weight: 500; color: var(--text); margin-bottom: 6px; }
        .form-control {
            width: 100%; padding: 10px 14px; border: 1px solid var(--border);
            border-radius: 8px; font-size: 13.5px; font-family: inherit;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-control:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(26,35,126,0.1); }
        select.form-control { cursor: pointer; }

        /* Grid */
        .grid { display: grid; gap: 20px; }
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
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
            .grid-4, .grid-3, .grid-2 { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- =========== SIDEBAR =========== -->
<nav class="sidebar">
    <div class="sidebar-brand">
        <h1><i class="bi bi-mortarboard-fill" style="color:var(--accent-lt)"></i> UCAD Cotisations</h1>
        <span>Gestion des Cotisations & Amendes</span>
    </div>

    <% if (currentUser != null) { %>
    <div class="sidebar-user d-flex align-items-center">
        <div class="avatar"><%
            String initials = currentUser.getEmail().substring(0,1).toUpperCase();
            out.print(initials);
        %></div>
        <div class="sidebar-user-info">
            <div class="name"><%= currentUser.getEmail() %></div>
            <div class="role"><%= "ADMIN".equals(currentRole) ? "Administrateur" : "Membre" %></div>
        </div>
    </div>
    <% } %>

    <div class="sidebar-nav">
        <div class="nav-section">Navigation</div>
        <div class="nav-item">
            <a href="<%= ctx %>/dashboard" class="<%= "dashboard".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-grid-1x2-fill"></i> Tableau de bord
            </a>
        </div>
        <% if ("ADMIN".equals(currentRole)) { %>
        <div class="nav-item">
            <a href="<%= ctx %>/membres" class="<%= "membres".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-people-fill"></i> Membres
            </a>
        </div>
        <% } %>
        <div class="nav-item">
            <a href="<%= ctx %>/cotisations" class="<%= "cotisations".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-cash-stack"></i> Cotisations
            </a>
        </div>
        <div class="nav-item">
            <a href="<%= ctx %>/amendes" class="<%= "amendes".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-exclamation-triangle-fill"></i> Amendes
            </a>
        </div>
    </div>

    <div class="sidebar-footer">
        <a href="<%= ctx %>/logout">
            <i class="bi bi-box-arrow-left"></i> Déconnexion
        </a>
    </div>
</nav>

<!-- =========== MAIN CONTENT =========== -->
<div class="main-content">
    <header class="topbar">
        <div class="topbar-title"><c:out value="${pageTitle != null ? pageTitle : 'Tableau de bord'}"/></div>
        <div class="topbar-actions">
            <span class="text-muted" style="font-size:12px">
                <i class="bi bi-clock"></i>
                <%= new java.text.SimpleDateFormat("EEE d MMM yyyy", new java.util.Locale("fr")).format(new java.util.Date()) %>
            </span>
        </div>
    </header>
    <div class="page-body">

        <%-- Messages flash --%>
        <% String successMsg = (String) session.getAttribute("successMsg");
           String errorMsg   = (String) session.getAttribute("errorMsg");
           if (successMsg != null) { session.removeAttribute("successMsg"); %>
        <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> <%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { session.removeAttribute("errorMsg"); %>
        <div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> <%= errorMsg %></div>
        <% } %>
