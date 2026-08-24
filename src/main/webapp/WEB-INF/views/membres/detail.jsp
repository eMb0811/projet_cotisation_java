<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    sn.ucad.cotisations.model.Membre membre = (sn.ucad.cotisations.model.Membre) request.getAttribute("membre");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
    if (membre != null) request.setAttribute("pageTitle", membre.getNomComplet());
    request.setAttribute("activePage", "membres");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex align-items-center gap-3 mb-4">
    <a href="<%= ctx %>/membres" class="btn btn-outline btn-sm"><i class="bi bi-arrow-left"></i> Retour</a>
    <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">Fiche Membre</h2>
</div>

<c:if test="${membre != null}">
<div class="grid grid-2 mb-4">
    <%-- Infos personnelles --%>
    <div class="card">
        <div class="card-header">
            <h5><i class="bi bi-person-circle"></i> Informations personnelles</h5>
            <a href="<%= ctx %>/membres?action=modifier&id=${membre.id}" class="btn btn-outline btn-sm"><i class="bi bi-pencil-fill"></i> Modifier</a>
        </div>
        <div class="card-body">
            <div style="text-align:center;margin-bottom:20px">
                <div style="width:72px;height:72px;background:var(--brand-primary);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:28px;font-weight:700;margin:0 auto 12px">
                    ${membre.prenom.charAt(0)}
                </div>
                <h3 style="font-size:18px;font-weight:700;color:var(--text-main)">${membre.nomComplet}</h3>
                <c:choose>
                    <c:when test="${membre.statut.name() == 'ACTIF'}"><span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Actif</span></c:when>
                    <c:when test="${membre.statut.name() == 'SUSPENDU'}"><span class="badge badge-warning">Suspendu</span></c:when>
                    <c:otherwise><span class="badge badge-muted">Inactif</span></c:otherwise>
                </c:choose>
            </div>
            <div style="display:flex;flex-direction:column;gap:10px">
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted"><i class="bi bi-envelope-fill"></i> Email</span>
                    <span style="font-weight:500">${membre.utilisateur.email}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted"><i class="bi bi-telephone-fill"></i> Téléphone</span>
                    <span style="font-weight:500">${membre.telephone}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted"><i class="bi bi-calendar3"></i> Adhésion</span>
                    <span style="font-weight:500">${membre.dateAdhesion}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0">
                    <span class="text-muted"><i class="bi bi-shield-fill"></i> Rôle</span>
                    <span style="font-weight:500">${membre.utilisateur.role}</span>
                </div>
            </div>
        </div>
    </div>

    <%-- Actions rapides --%>
    <div class="card">
        <div class="card-header"><h5><i class="bi bi-lightning-fill" style="color:var(--accent)"></i> Actions</h5></div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:10px">
                <a href="<%= ctx %>/cotisations?action=liste" class="btn btn-outline"><i class="bi bi-cash-stack"></i> Voir les cotisations</a>
                <a href="<%= ctx %>/amendes?action=liste" class="btn btn-outline"><i class="bi bi-exclamation-triangle-fill"></i> Voir les amendes</a>
                <% if ("ADMIN".equals(session.getAttribute("sessionRole"))) { %>
                <form method="post" action="<%= ctx %>/membres" style="margin-top:10px"
                      onsubmit="return confirm('⚠️ ATTENTION : Êtes-vous sûr de vouloir SUPPRIMER DÉFINITIVEMENT ce membre ? Cette opération est irréversible.')">
                    <input type="hidden" name="action" value="supprimer">
                    <input type="hidden" name="id" value="${membre.id}">
                    <button type="submit" class="btn btn-danger" style="width:100%">
                        <i class="bi bi-trash-fill"></i> Supprimer définitivement ce membre
                    </button>
                </form>
                <% } %>
            </div>
        </div>
    </div>
</div>
</c:if>
<c:if test="${membre == null}">
    <div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> Membre introuvable.</div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
