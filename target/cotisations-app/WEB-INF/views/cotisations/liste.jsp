<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Cotisations");
    request.setAttribute("activePage", "cotisations");
    String ctx = request.getContextPath();
    boolean isAdmin = "ADMIN".equals(session.getAttribute("sessionRole"));
    String devise = (String) request.getAttribute("devise");
    if (devise == null) devise = "FCFA";
    Integer moisParam = (Integer) request.getAttribute("mois");
    Integer anneeParam = (Integer) request.getAttribute("annee");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 style="font-size:20px;font-weight:700;color:var(--primary)">Cotisations</h2>
        <p class="text-muted">${cotisations.size()} cotisation(s)</p>
    </div>
    <div class="d-flex gap-2">
        <% if (isAdmin) { %>
        <a href="<%= ctx %>/cotisations?action=excel" class="btn btn-outline btn-sm"><i class="bi bi-file-earmark-excel"></i> Excel</a>
        <% } %>
    </div>
</div>

<%-- Filtre par période --%>
<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="<%= ctx %>/cotisations" class="d-flex gap-2 align-items-end" style="flex-wrap:wrap">
            <input type="hidden" name="action" value="periode">
            <div>
                <label class="form-label" style="font-size:12px">Mois</label>
                <select name="mois" class="form-control" style="width:120px">
                    <% String[] moisNoms = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
                       for (int m=1; m<=12; m++) { %>
                    <option value="<%= m %>" <%= moisParam != null && moisParam == m ? "selected" : "" %>><%= moisNoms[m] %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <label class="form-label" style="font-size:12px">Année</label>
                <select name="annee" class="form-control" style="width:100px">
                    <% int curYear = java.time.LocalDate.now().getYear();
                       for (int y = curYear-2; y <= curYear+1; y++) { %>
                    <option value="<%= y %>" <%= anneeParam != null && anneeParam == y ? "selected" : "" %>><%= y %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-filter"></i> Filtrer</button>
            <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm">Tout afficher</a>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <% if (isAdmin) { %><th>Membre</th><% } %>
                        <th>Période</th>
                        <th>Montant</th>
                        <th>Statut</th>
                        <th>Date paiement</th>
                        <th>Moyen</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${cotisations}">
                    <tr>
                        <% if (isAdmin) { %>
                        <td><strong>${c.membre.nomComplet}</strong><br><small class="text-muted">${c.membre.utilisateur.email}</small></td>
                        <% } %>
                        <td style="font-weight:500">${c.mois}/<strong>${c.annee}</strong></td>
                        <td><fmt:formatNumber value="${c.montant}" pattern="#,##0"/> <%= devise %></td>
                        <td>
                            <c:choose>
                                <c:when test="${c.statut.name() == 'PAYEE'}"><span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Payée</span></c:when>
                                <c:when test="${c.statut.name() == 'EN_RETARD'}"><span class="badge badge-danger"><i class="bi bi-x-circle-fill"></i> En retard</span></c:when>
                                <c:otherwise><span class="badge badge-warning"><i class="bi bi-hourglass-split"></i> En attente</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-muted" style="font-size:12px">
                            <c:out value="${c.datePaiement != null ? c.datePaiement : '—'}"/>
                        </td>
                        <td class="text-muted">
                            <c:out value="${c.moyenPaiement != null ? c.moyenPaiement : '—'}"/>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;flex-wrap:wrap">
                                <c:if test="${c.statut.name() != 'PAYEE'}">
                                    <a href="<%= ctx %>/cotisations?action=payer&id=${c.id}" class="btn btn-success btn-sm"><i class="bi bi-cash-coin"></i> Payer</a>
                                </c:if>
                                <c:if test="${c.statut.name() == 'PAYEE'}">
                                    <a href="<%= ctx %>/cotisations?action=pdf&id=${c.id}" class="btn btn-outline btn-sm" target="_blank"><i class="bi bi-file-earmark-pdf-fill"></i> Reçu</a>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty cotisations}">
                    <tr><td colspan="7" class="text-center" style="padding:48px">
                        <i class="bi bi-inbox" style="font-size:40px;color:#ccc;display:block;margin-bottom:8px"></i>
                        <span class="text-muted">Aucune cotisation trouvée pour cette période</span>
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
