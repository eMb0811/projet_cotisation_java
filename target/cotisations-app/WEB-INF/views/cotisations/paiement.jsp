<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    sn.ucad.cotisations.model.Cotisation cotisation = (sn.ucad.cotisations.model.Cotisation) request.getAttribute("cotisation");
    request.setAttribute("pageTitle", "Payer une cotisation");
    request.setAttribute("activePage", "cotisations");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex align-items-center gap-3 mb-4">
    <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm"><i class="bi bi-arrow-left"></i> Retour</a>
    <h2 style="font-size:20px;font-weight:700;color:var(--primary)">Enregistrer un paiement</h2>
</div>

<c:if test="${cotisation != null}">
<div style="max-width:540px">
    <%-- Résumé de la cotisation --%>
    <div class="card mb-4">
        <div class="card-header"><h5><i class="bi bi-receipt"></i> Détails de la cotisation</h5></div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:10px">
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Membre</span>
                    <strong>${cotisation.membre.nomComplet}</strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Période</span>
                    <strong>${cotisation.mois} / ${cotisation.annee}</strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Montant dû</span>
                    <strong style="color:var(--primary);font-size:18px">
                        <fmt:formatNumber value="${cotisation.montant}" pattern="#,##0"/> <%= devise %>
                    </strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0">
                    <span class="text-muted">Statut actuel</span>
                    <c:choose>
                        <c:when test="${cotisation.statut.name() == 'EN_RETARD'}"><span class="badge badge-danger">En retard</span></c:when>
                        <c:otherwise><span class="badge badge-warning">En attente</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- Formulaire paiement --%>
    <div class="card">
        <div class="card-header"><h5><i class="bi bi-cash-coin"></i> Mode de paiement</h5></div>
        <div class="card-body">
            <form method="post" action="<%= ctx %>/cotisations">
                <input type="hidden" name="action" value="payer">
                <input type="hidden" name="id" value="${cotisation.id}">

                <div class="form-group">
                    <label class="form-label" for="moyenPaiement">Moyen de paiement <span style="color:red">*</span></label>
                    <select id="moyenPaiement" name="moyenPaiement" class="form-control" required>
                        <option value="">-- Sélectionner --</option>
                        <c:forEach var="m" items="${moyens}">
                            <option value="${m}">${m}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="referencePaiement">Référence de paiement</label>
                    <input type="text" id="referencePaiement" name="referencePaiement" class="form-control"
                           placeholder="Ex: WAVE-20260105-8899 (optionnel)">
                </div>

                <div class="d-flex gap-2 mt-3">
                    <button type="submit" class="btn btn-success">
                        <i class="bi bi-check-lg"></i> Confirmer le paiement
                    </button>
                    <a href="<%= ctx %>/cotisations" class="btn btn-outline">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>
</c:if>
<c:if test="${cotisation == null}">
    <div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> Cotisation introuvable.</div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
