<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    sn.ucad.cotisations.model.Cotisation cotisation = (sn.ucad.cotisations.model.Cotisation) request.getAttribute("cotisation");
    request.setAttribute("pageTitle", "Régler une cotisation");
    request.setAttribute("activePage", "cotisations");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<style>
    .payment-container {
        max-width: 620px;
        margin: 0 auto 30px auto;
    }
    
    .payment-method-card {
        border: 2px solid var(--border-ui);
        border-radius: 10px;
        padding: 12px 14px;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        gap: 12px;
        background: #ffffff;
        user-select: none;
    }
    
    .payment-method-card:hover {
        border-color: #94a3b8;
        background: #f8fafc;
        transform: translateY(-1px);
    }
    
    .payment-method-card.selected {
        border-color: var(--brand-primary);
        background: #eff6ff;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }
    
    .method-logo {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
</style>

<div class="payment-container">
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div class="d-flex align-items-center gap-3">
            <a href="<%= ctx %>/cotisations" class="btn btn-outline btn-sm"><i class="bi bi-arrow-left"></i> Retour</a>
            <h2 style="font-size:20px;font-weight:700;color:var(--text-main);margin:0">Règlement de cotisation</h2>
        </div>
        <span class="badge badge-info" style="font-size:12px">Paiement sécurisé</span>
    </div>

    <c:if test="${cotisation != null}">
        <%-- Résumé de la cotisation --%>
        <div class="card mb-4">
            <div class="card-header">
                <h5><i class="bi bi-receipt"></i> Détails de la cotisation</h5>
                <c:choose>
                    <c:when test="${cotisation.statut.name() == 'EN_RETARD'}"><span class="badge badge-danger">En retard</span></c:when>
                    <c:otherwise><span class="badge badge-warning">En attente</span></c:otherwise>
                </c:choose>
            </div>
            <div class="card-body">
                <div style="display:flex;flex-direction:column;gap:12px">
                    <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:10px;border-bottom:1px solid #f1f5f9">
                        <span class="text-muted"><i class="bi bi-person-fill"></i> Membre</span>
                        <strong style="color:var(--text-main)">${cotisation.membre.nomComplet} (ID #${cotisation.membre.id})</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:10px;border-bottom:1px solid #f1f5f9">
                        <span class="text-muted"><i class="bi bi-calendar-event"></i> Période concernée</span>
                        <strong style="color:var(--text-main)">Mois ${cotisation.mois} / Année ${cotisation.annee}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;padding-top:4px">
                        <span style="font-weight:600;color:#334155;font-size:14px">Montant total à régler</span>
                        <strong style="color:var(--brand-primary);font-size:22px;font-weight:800">
                            <fmt:formatNumber value="${cotisation.montant}" pattern="#,##0"/> <%= devise %>
                        </strong>
                    </div>
                </div>
            </div>
        </div>

        <%-- Formulaire paiement --%>
        <div class="card">
            <div class="card-header">
                <h5><i class="bi bi-credit-card-2-front-fill" style="color:var(--brand-primary)"></i> Choisissez votre moyen de paiement</h5>
            </div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/cotisations" id="formPaiement">
                    <input type="hidden" name="action" value="payer">
                    <input type="hidden" name="id" value="${cotisation.id}">
                    <input type="hidden" name="moyenPaiement" id="moyenPaiementInput" value="MOBILE_MONEY">

                    <label class="form-label" style="margin-bottom:10px">Sélectionnez le canal de règlement <span style="color:red">*</span></label>
                    
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:20px">
                        <!-- Option 1 : Wave -->
                        <div class="payment-method-card selected" id="opt-wave" onclick="selectPaymentMethod('MOBILE_MONEY', 'WAVE', this)">
                            <img src="<%= ctx %>/assets/img/wave.svg" alt="Wave" class="method-logo" style="box-shadow:0 2px 4px rgba(0,0,0,0.1)">
                            <div>
                                <div style="font-weight:700;font-size:13.5px;color:#0f172a">Wave</div>
                                <div style="font-size:11px;color:#64748b">Paiement Mobile direct</div>
                            </div>
                        </div>

                        <!-- Option 2 : Orange Money -->
                        <div class="payment-method-card" id="opt-om" onclick="selectPaymentMethod('MOBILE_MONEY', 'OM', this)">
                            <img src="<%= ctx %>/assets/img/orange-money.svg" alt="Orange Money" class="method-logo" style="box-shadow:0 2px 4px rgba(0,0,0,0.1)">
                            <div>
                                <div style="font-weight:700;font-size:13.5px;color:#0f172a">Orange Money</div>
                                <div style="font-size:11px;color:#64748b">Code marchand / Transfert</div>
                            </div>
                        </div>

                        <!-- Option 3 : Carte Bancaire (Visa / Mastercard) -->
                        <div class="payment-method-card" id="opt-carte" onclick="selectPaymentMethod('VIREMENT', 'CARTE', this)">
                            <div style="display:flex;align-items:center;gap:4px">
                                <img src="<%= ctx %>/assets/img/visa.svg" alt="Visa" class="method-logo" style="width:34px;height:24px;border-radius:4px;box-shadow:0 1px 3px rgba(0,0,0,0.1)">
                                <img src="<%= ctx %>/assets/img/mastercard.svg" alt="Mastercard" class="method-logo" style="width:34px;height:24px;border-radius:4px;box-shadow:0 1px 3px rgba(0,0,0,0.1)">
                            </div>
                            <div>
                                <div style="font-weight:700;font-size:13.5px;color:#0f172a">Carte Bancaire</div>
                                <div style="font-size:11px;color:#64748b">Visa / Mastercard</div>
                            </div>
                        </div>

                        <!-- Option 4 : Virement bancaire -->
                        <div class="payment-method-card" id="opt-virement" onclick="selectPaymentMethod('VIREMENT', 'VIR', this)">
                            <div class="method-logo" style="background:#f1f5f9;color:#334155;font-size:18px">
                                <i class="bi bi-bank2"></i>
                            </div>
                            <div>
                                <div style="font-weight:700;font-size:13.5px;color:#0f172a">Virement bancaire</div>
                                <div style="font-size:11px;color:#64748b">Compte bancaire UCAD</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom:22px">
                        <label class="form-label" for="referencePaiement">
                            Référence ou ID de transaction <span class="text-muted" style="font-weight:400">(Recommandé)</span>
                        </label>
                        <div style="position:relative">
                            <i class="bi bi-hash" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#94a3b8;font-size:16px"></i>
                            <input type="text" id="referencePaiement" name="referencePaiement" class="form-control"
                                   style="padding-left:36px"
                                   placeholder="Ex: T-98472918 ou WAVE-REC-4821">
                        </div>
                        <span style="font-size:11.5px;color:#64748b;margin-top:4px;display:block">
                            Insérez le numéro de reçu ou SMS de confirmation pour faciliter le rapprochement comptable.
                        </span>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-success" style="padding:10px 22px;font-size:14px">
                            <i class="bi bi-check-circle-fill"></i> Confirmer et enregistrer le règlement
                        </button>
                        <a href="<%= ctx %>/cotisations" class="btn btn-outline" style="padding:10px 18px">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <c:if test="${cotisation == null}">
        <div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> Cotisation introuvable.</div>
    </c:if>
</div>

<script>
    function selectPaymentMethod(enumValue, prefix, cardElement) {
        document.getElementById('moyenPaiementInput').value = enumValue;
        document.querySelectorAll('.payment-method-card').forEach(el => el.classList.remove('selected'));
        cardElement.classList.add('selected');
        
        const refInput = document.getElementById('referencePaiement');
        if (prefix === 'WAVE') {
            refInput.placeholder = "Ex: WAVE-REC-" + Math.floor(100000 + Math.random() * 900000);
        } else if (prefix === 'OM') {
            refInput.placeholder = "Ex: OM-SN-" + Math.floor(100000 + Math.random() * 900000);
        } else if (prefix === 'CARTE') {
            refInput.placeholder = "Ex: CARD-AUTH-" + Math.floor(100000 + Math.random() * 900000);
        } else if (prefix === 'VIR') {
            refInput.placeholder = "Ex: VIR-BCAO-78921";
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
