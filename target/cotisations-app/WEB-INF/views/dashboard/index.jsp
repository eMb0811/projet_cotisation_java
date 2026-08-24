<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Tableau de bord");
    request.setAttribute("activePage", "dashboard");
    String ctx = request.getContextPath();
    String role = (String) session.getAttribute("sessionRole");
    boolean isAdmin = "ADMIN".equals(role);
    String devise = (String) request.getAttribute("devise");
    if (devise == null) devise = "FCFA";
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- KPI Cards --%>
<div class="grid grid-4 mb-4">
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#e8eaf6; color:#1a237e">
            <i class="bi bi-people-fill"></i>
        </div>
        <div class="kpi-info">
            <div class="value">${nbMembresActifs}</div>
            <div class="label">Membres actifs</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#e8f5e9; color:#2e7d32">
            <i class="bi bi-cash-stack"></i>
        </div>
        <div class="kpi-info">
            <div class="value" style="font-size:18px">
                <fmt:formatNumber value="${totalCotisationsPayees}" pattern="#,##0"/>
            </div>
            <div class="label">Total encaissé (<%= devise %>)</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#fff8e1; color:#e65100">
            <i class="bi bi-hourglass-split"></i>
        </div>
        <div class="kpi-info">
            <div class="value">${nbCotisationsEnRetard}</div>
            <div class="label">Cotisations en retard</div>
        </div>
    </div>
    <div class="kpi-card">
        <div class="kpi-icon" style="background:#ffebee; color:#c62828">
            <i class="bi bi-exclamation-triangle-fill"></i>
        </div>
        <div class="kpi-info">
            <div class="value" style="font-size:18px">
                <fmt:formatNumber value="${totalAmendesImpayees}" pattern="#,##0"/>
            </div>
            <div class="label">Amendes impayées (<%= devise %>)</div>
        </div>
    </div>
</div>

<% if (isAdmin) { %>

<%-- Section Admin : Actions rapides --%>
<div class="grid grid-2 mb-4">
    <div class="card">
        <div class="card-header">
            <h5><i class="bi bi-lightning-fill" style="color:var(--accent)"></i> Actions rapides</h5>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:12px">
                <%-- Générer cotisations --%>
                <form method="post" action="<%= ctx %>/cotisations" style="display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap">
                    <input type="hidden" name="action" value="generer">
                    <div>
                        <label style="font-size:12px;font-weight:500;color:#555;display:block;margin-bottom:4px">Mois</label>
                        <select name="mois" style="padding:8px 12px;border:1px solid #ddd;border-radius:7px;font-size:13px">
                            <% String[] moisNoms = {"","Jan","Fév","Mar","Avr","Mai","Juin","Juil","Août","Sep","Oct","Nov","Déc"};
                               java.time.LocalDate now = java.time.LocalDate.now();
                               for (int m=1; m<=12; m++) { %>
                            <option value="<%= m %>" <%= m == now.getMonthValue() ? "selected" : "" %>><%= moisNoms[m] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label style="font-size:12px;font-weight:500;color:#555;display:block;margin-bottom:4px">Année</label>
                        <select name="annee" style="padding:8px 12px;border:1px solid #ddd;border-radius:7px;font-size:13px">
                            <% for (int y = now.getYear()-1; y <= now.getYear()+1; y++) { %>
                            <option value="<%= y %>" <%= y == now.getYear() ? "selected" : "" %>><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-plus-circle"></i> Générer cotisations</button>
                </form>

                <%-- Traiter retards --%>
                <form method="post" action="<%= ctx %>/cotisations" style="display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap">
                    <input type="hidden" name="action" value="retards">
                    <div>
                        <label style="font-size:12px;font-weight:500;color:#555;display:block;margin-bottom:4px">Mois (retards)</label>
                        <select name="mois" style="padding:8px 12px;border:1px solid #ddd;border-radius:7px;font-size:13px">
                            <% for (int m=1; m<=12; m++) { %>
                            <option value="<%= m %>" <%= m == now.getMonthValue() ? "selected" : "" %>><%= moisNoms[m] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label style="font-size:12px;font-weight:500;color:#555;display:block;margin-bottom:4px">Année</label>
                        <select name="annee" style="padding:8px 12px;border:1px solid #ddd;border-radius:7px;font-size:13px">
                            <% for (int y = now.getYear()-1; y <= now.getYear()+1; y++) { %>
                            <option value="<%= y %>" <%= y == now.getYear() ? "selected" : "" %>><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-accent btn-sm"><i class="bi bi-exclamation-circle"></i> Traiter retards</button>
                </form>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h5><i class="bi bi-bar-chart-fill" style="color:var(--primary)"></i> Résumé</h5>
        </div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:12px">
                <div style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #f0f0f0">
                    <span style="font-size:13.5px;color:#555">Cotisations payées</span>
                    <span class="badge badge-success">${nbMembresActifs - nbCotisationsEnRetard}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #f0f0f0">
                    <span style="font-size:13.5px;color:#555">En retard</span>
                    <span class="badge badge-danger">${nbCotisationsEnRetard}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:10px 0">
                    <span style="font-size:13.5px;color:#555">Amendes impayées</span>
                    <span class="badge badge-warning">${nbAmendesImpayees}</span>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Cotisations récentes --%>
<div class="card mb-4">
    <div class="card-header">
        <h5><i class="bi bi-clock-history"></i> Cotisations récentes</h5>
        <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm">Voir tout</a>
    </div>
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table>
                <thead><tr>
                    <th>Membre</th><th>Période</th><th>Montant</th><th>Statut</th><th>Date paiement</th>
                </tr></thead>
                <tbody>
                <c:forEach var="c" items="${cotisationsRecentes}">
                    <tr>
                        <td><strong>${c.membre.nomComplet}</strong></td>
                        <td>${c.mois}/${c.annee}</td>
                        <td><fmt:formatNumber value="${c.montant}" pattern="#,##0"/> <%= devise %></td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut.name() == 'PAYEE'}"><span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Payée</span></c:when>
                                <c:when test="${c.statut.name() == 'EN_RETARD'}"><span class="badge badge-danger"><i class="bi bi-x-circle-fill"></i> En retard</span></c:when>
                                <c:otherwise><span class="badge badge-warning"><i class="bi bi-hourglass-split"></i> En attente</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-muted"><c:out value="${c.datePaiement != null ? c.datePaiement : '—'}"/></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty cotisationsRecentes}">
                    <tr><td colspan="5" class="text-center text-muted" style="padding:32px">Aucune cotisation</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<% } else { %>
<%-- Vue Membre --%>
<div class="grid grid-2 mb-4">
    <div class="card">
        <div class="card-header"><h5><i class="bi bi-cash-stack"></i> Mes cotisations</h5><a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm">Voir tout</a></div>
        <div class="card-body" style="padding:0">
            <table>
                <thead><tr><th>Période</th><th>Montant</th><th>Statut</th></tr></thead>
                <tbody>
                <c:forEach var="c" items="${mesCotisations}">
                    <tr>
                        <td>${c.mois}/${c.annee}</td>
                        <td><fmt:formatNumber value="${c.montant}" pattern="#,##0"/> <%= devise %></td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut.name() == 'PAYEE'}"><span class="badge badge-success">Payée</span></c:when>
                                <c:when test="${c.statut.name() == 'EN_RETARD'}"><span class="badge badge-danger">En retard</span></c:when>
                                <c:otherwise><span class="badge badge-warning">En attente</span></c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty mesCotisations}"><tr><td colspan="3" class="text-center text-muted" style="padding:24px">Aucune cotisation</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h5><i class="bi bi-exclamation-triangle-fill"></i> Mes amendes</h5><a href="<%= ctx %>/amendes" class="btn btn-outline btn-sm">Voir tout</a></div>
        <div class="card-body" style="padding:0">
            <table>
                <thead><tr><th>Motif</th><th>Montant</th><th>Statut</th></tr></thead>
                <tbody>
                <c:forEach var="a" items="${mesAmendes}">
                    <tr>
                        <td>${a.motif}</td>
                        <td><fmt:formatNumber value="${a.montant}" pattern="#,##0"/> <%= devise %></td>
                        <td><c:choose>
                            <c:when test="${a.statut.name() == 'PAYEE'}"><span class="badge badge-success">Payée</span></c:when>
                            <c:otherwise><span class="badge badge-danger">Impayée</span></c:otherwise>
                        </c:choose></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty mesAmendes}"><tr><td colspan="3" class="text-center text-muted" style="padding:24px">Aucune amende</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
<% } %>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
