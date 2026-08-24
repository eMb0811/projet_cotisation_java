<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Amendes");
    request.setAttribute("activePage", "amendes");
    String ctx = request.getContextPath();
    boolean isAdmin = "ADMIN".equals(session.getAttribute("sessionRole"));
    String devise = (String) request.getAttribute("devise");
    if (devise == null) devise = "FCFA";
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 style="font-size:20px;font-weight:700;color:var(--primary)">Amendes</h2>
        <p class="text-muted">${amendes.size()} amende(s)</p>
    </div>
</div>

<%-- Création amende (admin only) --%>
<% if (isAdmin) { %>
<div class="card mb-4">
    <div class="card-header">
        <h5><i class="bi bi-plus-circle-fill" style="color:var(--accent)"></i> Nouvelle amende</h5>
    </div>
    <div class="card-body">
        <form method="post" action="<%= ctx %>/amendes" class="d-flex gap-2 align-items-end" style="flex-wrap:wrap">
            <input type="hidden" name="action" value="creer">
            <div>
                <label class="form-label" style="font-size:12px">ID Membre</label>
                <input type="number" name="membreId" class="form-control" placeholder="ID" required style="width:100px">
            </div>
            <div style="flex:1;min-width:200px">
                <label class="form-label" style="font-size:12px">Motif</label>
                <input type="text" name="motif" class="form-control" placeholder="Motif de l'amende" required>
            </div>
            <div>
                <label class="form-label" style="font-size:12px">Montant (<%= devise %>)</label>
                <input type="number" name="montant" class="form-control" placeholder="2500" step="0.01" style="width:120px">
            </div>
            <button type="submit" class="btn btn-accent btn-sm"><i class="bi bi-plus-lg"></i> Créer</button>
        </form>
    </div>
</div>
<% } %>

<div class="card">
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <% if (isAdmin) { %><th>Membre</th><% } %>
                        <th>Motif</th>
                        <th>Montant</th>
                        <th>Date génération</th>
                        <th>Statut</th>
                        <th>Date paiement</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="a" items="${amendes}">
                    <tr>
                        <% if (isAdmin) { %>
                        <td><strong>${a.membre.nomComplet}</strong></td>
                        <% } %>
                        <td style="max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis" title="${a.motif}">
                            ${a.motif}
                        </td>
                        <td>
                            <strong style="color:var(--danger)">
                                <fmt:formatNumber value="${a.montant}" pattern="#,##0"/> <%= devise %>
                            </strong>
                        </td>
                        <td class="text-muted" style="font-size:12px"><c:out value="${a.dateGeneration}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${a.statut.name() == 'PAYEE'}"><span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Payée</span></c:when>
                                <c:otherwise><span class="badge badge-danger"><i class="bi bi-x-circle-fill"></i> Impayée</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-muted" style="font-size:12px"><c:out value="${a.datePaiement != null ? a.datePaiement : '—'}"/></td>
                        <td>
                            <c:if test="${a.statut.name() != 'PAYEE'}">
                                <a href="<%= ctx %>/amendes?action=payer&id=${a.id}" class="btn btn-success btn-sm"><i class="bi bi-cash-coin"></i> Payer</a>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty amendes}">
                    <tr><td colspan="7" class="text-center" style="padding:48px">
                        <i class="bi bi-shield-check" style="font-size:40px;color:#ccc;display:block;margin-bottom:8px"></i>
                        <span class="text-muted">Aucune amende</span>
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
