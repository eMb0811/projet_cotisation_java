<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Tableau de bord Administrateur");
    request.setAttribute("activePage", "dashboard");
    String ctx = request.getContextPath();
    String devise = (String) request.getAttribute("devise");
    if (devise == null) devise = "FCFA";
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="mb-4">
    <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">Vue d'ensemble financière & opérationnelle</h2>
    <p class="text-muted">Suivi des adhésions, des flux de cotisations et du recouvrement des amendes.</p>
</div>

<%-- KPI Cards Claires --%>
<div class="grid grid-4 mb-4">
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#eff6ff; color:#1e40af">
            <i class="bi bi-people-fill"></i>
        </div>
        <div class="kpi-info">
            <div class="value">${nbMembresActifs}</div>
            <div class="label">Membres actifs</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#ecfdf5; color:#065f46">
            <i class="bi bi-cash-stack"></i>
        </div>
        <div class="kpi-info">
            <div class="value" style="font-size:20px">
                <fmt:formatNumber value="${totalCotisationsPayees}" pattern="#,##0"/>
            </div>
            <div class="label">Total perçu (<%= devise %>)</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#fffbeb; color:#b45309">
            <i class="bi bi-hourglass-split"></i>
        </div>
        <div class="kpi-info">
            <div class="value">${nbCotisationsEnRetard}</div>
            <div class="label">Cotisations en retard</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#fef2f2; color:#991b1b">
            <i class="bi bi-exclamation-triangle-fill"></i>
        </div>
        <div class="kpi-info">
            <div class="value" style="font-size:20px">
                <fmt:formatNumber value="${totalAmendesImpayees}" pattern="#,##0"/>
            </div>
            <div class="label">Amendes à recouvrer (<%= devise %>)</div>
        </div>
    </div>
</div>

<%-- Section Actions Rapides & Résumé --%>
<div class="grid grid-2 mb-4">
    <%-- Formulaire Actions rapides --%>
    <div class="card">
        <div class="card-header">
            <h5><i class="bi bi-lightning-charge-fill" style="color:#d97706"></i> Actions administratives</h5>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:18px">
                <%-- Générer cotisations avec saisie du montant --%>
                <form method="post" action="<%= ctx %>/cotisations" style="background:#f8fafc;padding:14px;border-radius:10px;border:1px solid var(--border-ui)">
                    <input type="hidden" name="action" value="generer">
                    <span style="font-size:13px;font-weight:700;color:var(--text-main);display:block;margin-bottom:8px">
                        <i class="bi bi-plus-circle-fill" style="color:var(--brand-primary)"></i> Générer les cotisations mensuelles
                    </span>
                    <div class="grid grid-3 mb-3">
                        <div>
                            <label class="form-label" style="font-size:11.5px;margin-bottom:3px">Mois</label>
                            <select name="mois" class="form-control" style="font-size:13px;padding:7px 10px">
                                <% String[] moisNoms = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
                                   java.time.LocalDate now = java.time.LocalDate.now();
                                   for (int m=1; m<=12; m++) { %>
                                <option value="<%= m %>" <%= m == now.getMonthValue() ? "selected" : "" %>><%= moisNoms[m] %></option>
                                <% } %>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" style="font-size:11.5px;margin-bottom:3px">Année</label>
                            <select name="annee" class="form-control" style="font-size:13px;padding:7px 10px">
                                <% for (int y = now.getYear()-1; y <= now.getYear()+1; y++) { %>
                                <option value="<%= y %>" <%= y == now.getYear() ? "selected" : "" %>><%= y %></option>
                                <% } %>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" style="font-size:11.5px;margin-bottom:3px">Montant (<%= devise %>)</label>
                            <input type="number" step="500" min="1000" name="montant" class="form-control" 
                                   value="10000" style="font-size:13px;padding:7px 10px" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm" style="width:100%">
                        <i class="bi bi-play-fill"></i> Lancer la génération
                    </button>
                </form>

                <%-- Traiter retards --%>
                <form method="post" action="<%= ctx %>/cotisations" style="background:#f8fafc;padding:14px;border-radius:10px;border:1px solid var(--border-ui)">
                    <input type="hidden" name="action" value="retards">
                    <span style="font-size:13px;font-weight:700;color:var(--text-main);display:block;margin-bottom:8px">
                        <i class="bi bi-exclamation-octagon-fill" style="color:#d97706"></i> Détecter les retards et appliquer les amendes
                    </span>
                    <div class="grid grid-2 mb-3">
                        <div>
                            <label class="form-label" style="font-size:11.5px;margin-bottom:3px">Mois concerné</label>
                            <select name="mois" class="form-control" style="font-size:13px;padding:7px 10px">
                                <% for (int m=1; m<=12; m++) { %>
                                <option value="<%= m %>" <%= m == (now.getMonthValue() > 1 ? now.getMonthValue()-1 : 12) ? "selected" : "" %>><%= moisNoms[m] %></option>
                                <% } %>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" style="font-size:11.5px;margin-bottom:3px">Année</label>
                            <select name="annee" class="form-control" style="font-size:13px;padding:7px 10px">
                                <% for (int y = now.getYear()-1; y <= now.getYear()+1; y++) { %>
                                <option value="<%= y %>" <%= y == now.getYear() ? "selected" : "" %>><%= y %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-accent btn-sm" style="width:100%">
                        <i class="bi bi-shield-exclamation"></i> Détecter les retards
                    </button>
                </form>
            </div>
        </div>
    </div>

    <%-- Synthèse d'activité --%>
    <div class="card">
        <div class="card-header">
            <h5><i class="bi bi-pie-chart-fill" style="color:var(--brand-primary)"></i> Synthèse de la situation</h5>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:14px">
                <div style="display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid var(--border-ui)">
                    <span style="font-size:13.5px;color:var(--text-muted)">Adhérents régularisés ce mois</span>
                    <span class="badge badge-success">${nbMembresActifs - nbCotisationsEnRetard} membre(s)</span>
                </div>
                <div style="display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid var(--border-ui)">
                    <span style="font-size:13.5px;color:var(--text-muted)">Cotisations en souffrance</span>
                    <span class="badge badge-danger">${nbCotisationsEnRetard} en retard</span>
                </div>
                <div style="display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid var(--border-ui)">
                    <span style="font-size:13.5px;color:var(--text-muted)">Amendes en attente de paiement</span>
                    <span class="badge badge-warning">${nbAmendesImpayees} impayée(s)</span>
                </div>
                <div class="mt-3">
                    <a href="<%= ctx %>/cotisations?filtre=moi" class="btn btn-outline btn-sm" style="width:100%">
                        <i class="bi bi-person-circle"></i> Consulter mes propres cotisations (Admin)
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Tableau des cotisations récentes --%>
<div class="card">
    <div class="card-header">
        <h5><i class="bi bi-clock-history"></i> Transactions récentes</h5>
        <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm">Consulter tout</a>
    </div>
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Membre</th>
                        <th>Période</th>
                        <th>Montant</th>
                        <th>Statut</th>
                        <th>Date de règlement</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${cotisationsRecentes}">
                    <tr>
                        <td>
                            <div style="font-weight:600;color:var(--text-main)">${c.membre.nomComplet}</div>
                            <small class="text-muted">${c.membre.utilisateur.email}</small>
                        </td>
                        <td style="font-weight:600">${c.mois}/${c.annee}</td>
                        <td>
                            <strong style="color:var(--brand-primary)">
                                <fmt:formatNumber value="${c.montant}" pattern="#,##0"/>
                            </strong> <%= devise %>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut.name() == 'PAYEE'}">
                                    <span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Payée</span>
                                </c:when>
                                <c:when test="${c.statut.name() == 'EN_RETARD'}">
                                    <span class="badge badge-danger"><i class="bi bi-exclamation-triangle-fill"></i> En retard</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-warning"><i class="bi bi-hourglass-split"></i> En attente</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-muted" style="font-size:12.5px">
                            <c:out value="${c.datePaiement != null ? c.datePaiement : '—'}"/>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty cotisationsRecentes}">
                    <tr><td colspan="5" class="text-center text-muted" style="padding:32px">Aucune transaction récente</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
