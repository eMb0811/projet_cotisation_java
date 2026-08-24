<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String currentRole = (String) session.getAttribute("sessionRole");
    boolean isAdmin = "ADMIN".equals(currentRole);
    request.setAttribute("pageTitle", isAdmin ? "Gestion des Cotisations" : "Mes Cotisations");
    request.setAttribute("activePage", "cotisations");
    String ctx = request.getContextPath();
    String devise = (String) request.getAttribute("devise");
    if (devise == null) devise = "FCFA";
    Integer moisParam = (Integer) request.getAttribute("mois");
    Integer anneeParam = (Integer) request.getAttribute("annee");
    Boolean filtreMoi = (Boolean) request.getAttribute("filtreMoi");
    boolean isFiltreMoi = filtreMoi != null && filtreMoi;
    java.math.BigDecimal montantDefaut = (java.math.BigDecimal) request.getAttribute("montantDefaut");
    if (montantDefaut == null) montantDefaut = new java.math.BigDecimal("10000.00");
    // ID du membre connecté (pour l'admin : ne montrer Régler que pour ses propres cotisations)
    sn.ucad.cotisations.model.Membre sessionMembre = (sn.ucad.cotisations.model.Membre) session.getAttribute("sessionMembre");
    Long sessionMembreId = (sessionMembre != null) ? sessionMembre.getId() : null;
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4" style="flex-wrap:wrap;gap:12px">
    <div>
        <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">
            <%= isAdmin ? (isFiltreMoi ? "Mes Cotisations Personnelles" : "Toutes les Cotisations") : "Mes Cotisations" %>
        </h2>
        <p class="text-muted">${cotisations.size()} cotisation(s) enregistrée(s)</p>
    </div>
    <div class="d-flex gap-2" style="flex-wrap:wrap">
        <% if (isAdmin) { %>
            <% if (isFiltreMoi) { %>
                <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm">
                    <i class="bi bi-people-fill"></i> Voir toutes les cotisations
                </a>
            <% } else { %>
                <a href="<%= ctx %>/cotisations?filtre=moi" class="btn btn-outline btn-sm">
                    <i class="bi bi-person-check-fill"></i> Mes cotisations uniquement
                </a>
            <% } %>
            <a href="<%= ctx %>/cotisations?action=excel" class="btn btn-outline btn-sm">
                <i class="bi bi-file-earmark-excel-fill" style="color:#059669"></i> Exporter Excel
            </a>
            <button type="button" onclick="document.getElementById('modalGeneration').style.display='block'" class="btn btn-primary btn-sm">
                <i class="bi bi-plus-circle-fill"></i> Générer mensualité
            </button>
        <% } %>
    </div>
</div>

<%-- Formulaire modal de génération des cotisations avec saisie libre du montant pour l'admin --%>
<% if (isAdmin) { %>
<div id="modalGeneration" class="card mb-4" style="display:none;background:#f8fafc;border:2px dashed var(--border-ui);">
    <div class="card-header" style="background:#ffffff">
        <h5><i class="bi bi-calculator-fill" style="color:var(--brand-primary)"></i> Génération mensuelle des cotisations</h5>
        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('modalGeneration').style.display='none'">
            <i class="bi bi-x-lg"></i> Fermer
        </button>
    </div>
    <div class="card-body">
        <form method="post" action="<%= ctx %>/cotisations" class="grid grid-4 align-items-end">
            <input type="hidden" name="action" value="generer">
            
            <div class="form-group" style="margin-bottom:0">
                <label class="form-label" style="font-size:12px">Mois concerné</label>
                <select name="mois" class="form-control">
                    <% 
                       String[] moisNoms = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
                       java.time.LocalDate now = java.time.LocalDate.now();
                       for (int m=1; m<=12; m++) { 
                    %>
                    <option value="<%= m %>" <%= m == now.getMonthValue() ? "selected" : "" %>><%= moisNoms[m] %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom:0">
                <label class="form-label" style="font-size:12px">Année</label>
                <select name="annee" class="form-control">
                    <% for (int y = now.getYear()-1; y <= now.getYear()+1; y++) { %>
                    <option value="<%= y %>" <%= y == now.getYear() ? "selected" : "" %>><%= y %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom:0">
                <label class="form-label" style="font-size:12px">Montant par membre (<%= devise %>)</label>
                <input type="number" step="500" min="1000" name="montant" class="form-control" 
                       value="<%= montantDefaut %>" placeholder="Ex: 10000" required>
            </div>

            <div>
                <button type="submit" class="btn btn-primary" style="width:100%">
                    <i class="bi bi-magic"></i> Lancer la génération
                </button>
            </div>
        </form>
    </div>
</div>
<% } %>

<%-- Filtre par période --%>
<div class="card mb-4">
    <div class="card-body" style="padding:14px 20px">
        <form method="get" action="<%= ctx %>/cotisations" class="d-flex gap-2 align-items-end" style="flex-wrap:wrap">
            <input type="hidden" name="action" value="periode">
            <% if (isFiltreMoi) { %><input type="hidden" name="filtre" value="moi"><% } %>
            
            <div>
                <label class="form-label" style="font-size:11.5px;margin-bottom:4px">Filtrer par Mois</label>
                <select name="mois" class="form-control" style="width:130px;padding:7px 10px;font-size:13px">
                    <% String[] moisNomsFiltre = {"","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
                       for (int m=1; m<=12; m++) { %>
                    <option value="<%= m %>" <%= moisParam != null && moisParam == m ? "selected" : "" %>><%= moisNomsFiltre[m] %></option>
                    <% } %>
                </select>
            </div>

            <div>
                <label class="form-label" style="font-size:11.5px;margin-bottom:4px">Année</label>
                <select name="annee" class="form-control" style="width:100px;padding:7px 10px;font-size:13px">
                    <% int curYear = java.time.LocalDate.now().getYear();
                       for (int y = curYear-2; y <= curYear+1; y++) { %>
                    <option value="<%= y %>" <%= anneeParam != null && anneeParam == y ? "selected" : "" %>><%= y %></option>
                    <% } %>
                </select>
            </div>

            <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-filter"></i> Filtrer</button>
            <a href="<%= ctx %>/cotisations<%= isFiltreMoi ? "?filtre=moi" : "" %>" class="btn btn-outline btn-sm">Réinitialiser</a>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <% if (isAdmin && !isFiltreMoi) { %><th>Adhérent</th><% } %>
                        <th>Période</th>
                        <th>Montant</th>
                        <th>Statut</th>
                        <th>Date de paiement</th>
                        <th>Mode de règlement</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${cotisations}">
                    <tr>
                        <% if (isAdmin && !isFiltreMoi) { %>
                        <td>
                            <div style="font-weight:600;color:var(--text-main)">${c.membre.nomComplet}</div>
                            <small class="text-muted">${c.membre.telephone}</small>
                        </td>
                        <% } %>
                        <td style="font-weight:600">${c.mois}/<strong>${c.annee}</strong></td>
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
                        <td class="text-muted">
                            <c:choose>
                                <c:when test="${c.moyenPaiement != null}">
                                    <span class="badge badge-muted">${c.moyenPaiement}</span>
                                    <c:if test="${not empty c.referencePaiement}">
                                        <br><small class="text-muted" style="font-size:11px">${c.referencePaiement}</small>
                                    </c:if>
                                </c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;flex-wrap:wrap">
                                <%--
                                    L'admin ne peut RÉGLER que SA PROPRE cotisation.
                                    Pour les cotisations des autres membres, il voit juste le statut.
                                    Un membre ne voit que ses propres lignes, donc toujours autorisé.
                                --%>
                                <c:choose>
                                    <c:when test="${c.statut.name() != 'PAYEE'}">
                                        <c:if test="${sessionScope.sessionRole != 'ADMIN' || isFiltreMoi || (sessionScope.sessionMembre != null && sessionScope.sessionMembre.id == c.membre.id)}">
                                            <a href="<%= ctx %>/cotisations?action=payer&id=${c.id}" class="btn btn-success btn-sm">
                                                <i class="bi bi-credit-card-fill"></i> Régler
                                            </a>
                                        </c:if>
                                    </c:when>
                                    <c:when test="${c.statut.name() == 'PAYEE'}">
                                        <a href="<%= ctx %>/cotisations?action=pdf&id=${c.id}" class="btn btn-outline btn-sm" target="_blank" title="Reçu PDF">
                                            <i class="bi bi-file-earmark-pdf-fill" style="color:#dc2626"></i> Reçu
                                        </a>
                                    </c:when>
                                </c:choose>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty cotisations}">
                    <tr>
                        <td colspan="7" class="text-center" style="padding:48px">
                            <i class="bi bi-inbox" style="font-size:40px;color:#cbd5e1;display:block;margin-bottom:8px"></i>
                            <span class="text-muted">Aucune cotisation enregistrée pour cette sélection</span>
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
