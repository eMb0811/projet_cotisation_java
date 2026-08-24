<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    sn.ucad.cotisations.model.Amende amende = (sn.ucad.cotisations.model.Amende) request.getAttribute("amende");
    request.setAttribute("pageTitle", "Payer une amende");
    request.setAttribute("activePage", "amendes");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex align-items-center gap-3 mb-4">
    <a href="<%= ctx %>/amendes" class="btn btn-outline btn-sm"><i class="bi bi-arrow-left"></i> Retour</a>
    <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">Régler une amende</h2>
</div>

<c:if test="${amende != null}">
<div style="max-width:540px">
    <div class="card mb-4">
        <div class="card-header"><h5><i class="bi bi-exclamation-triangle-fill" style="color:var(--danger)"></i> Détails de l'amende</h5></div>
        <div class="card-body">
            <div style="display:flex;flex-direction:column;gap:10px">
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Membre</span>
                    <strong>${amende.membre.nomComplet}</strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Motif</span>
                    <span style="text-align:right;max-width:250px">${amende.motif}</span>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #f0f0f0">
                    <span class="text-muted">Montant dû</span>
                    <strong style="color:var(--danger);font-size:20px">
                        <fmt:formatNumber value="${amende.montant}" pattern="#,##0"/> <%= devise %>
                    </strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0">
                    <span class="text-muted">Date de génération</span>
                    <span>${amende.dateGeneration}</span>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h5><i class="bi bi-cash-coin"></i> Mode de règlement</h5></div>
        <div class="card-body">
            <form method="post" action="<%= ctx %>/amendes">
                <input type="hidden" name="action" value="payer">
                <input type="hidden" name="id" value="${amende.id}">
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
                    <label class="form-label" for="referencePaiement">Référence (optionnel)</label>
                    <input type="text" id="referencePaiement" name="referencePaiement" class="form-control" placeholder="Référence de transaction">
                </div>
                <div class="d-flex gap-2 mt-3">
                    <button type="submit" class="btn btn-success"><i class="bi bi-check-lg"></i> Confirmer le règlement</button>
                    <a href="<%= ctx %>/amendes" class="btn btn-outline">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
