<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    request.setAttribute("pageTitle", "Mon Profil");
    request.setAttribute("activePage", "profil");
    String ctx = request.getContextPath();
    sn.ucad.cotisations.model.Utilisateur user = (sn.ucad.cotisations.model.Utilisateur) request.getAttribute("user");
    sn.ucad.cotisations.model.Membre membre = (sn.ucad.cotisations.model.Membre) request.getAttribute("membre");
    boolean isAdmin = "ADMIN".equals(session.getAttribute("sessionRole"));
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="mb-4">
    <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">Gestion du profil</h2>
    <p class="text-muted">Consultez vos informations personnelles et sécurisez votre compte.</p>
</div>

<div class="grid grid-3">
    <%-- Carte récapitulative --%>
    <div>
        <div class="card">
            <div class="card-header">
                <h5><i class="bi bi-person-badge-fill"></i> Identité du compte</h5>
            </div>
            <div class="card-body text-center" style="padding:28px 20px">
                <div style="width:72px;height:72px;background:var(--brand-primary);border-radius:50%;display:inline-flex;align-items:center;justify-content:center;color:white;font-size:28px;font-weight:700;margin-bottom:16px;box-shadow:0 4px 12px rgba(0,0,0,0.1)">
                    <c:choose>
                        <c:when test="${membre != null && not empty membre.prenom}">
                            ${membre.prenom.substring(0,1).toUpperCase()}
                        </c:when>
                        <c:otherwise>
                            ${user.email.substring(0,1).toUpperCase()}
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <h3 style="font-size:17px;font-weight:700;color:var(--text-main);margin-bottom:4px">
                    <c:choose>
                        <c:when test="${membre != null}">${membre.nomComplet}</c:when>
                        <c:otherwise>${user.email}</c:otherwise>
                    </c:choose>
                </h3>
                
                <p style="font-size:13px;color:var(--text-muted);margin-bottom:14px">${user.email}</p>

                <div style="display:inline-block;padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;background:var(--role-badge-bg);color:var(--role-badge-txt);margin-bottom:20px">
                    ${isAdmin ? '🛡️ Administrateur Général' : '👤 Membre Adhérent'}
                </div>

                <div style="text-align:left;border-top:1px solid var(--border-ui);padding-top:16px;font-size:13px;display:flex;flex-direction:column;gap:10px">
                    <div style="display:flex;justify-content:space-between">
                        <span class="text-muted">Statut du compte</span>
                        <span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Actif</span>
                    </div>
                    <c:if test="${membre != null}">
                        <div style="display:flex;justify-content:space-between">
                            <span class="text-muted">Téléphone</span>
                            <strong>${membre.telephone}</strong>
                        </div>
                        <div style="display:flex;justify-content:space-between">
                            <span class="text-muted">Date d'adhésion</span>
                            <strong>${membre.dateAdhesion}</strong>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <%-- Formulaires de modification --%>
    <div style="grid-column: span 2;">
        <%-- Formulaire 1 : Informations personnelles --%>
        <c:if test="${membre != null}">
            <div class="card mb-4">
                <div class="card-header">
                    <h5><i class="bi bi-pencil-square"></i> Modifier mes coordonnées</h5>
                </div>
                <div class="card-body">
                    <form method="post" action="<%= ctx %>/profil">
                        <input type="hidden" name="action" value="update-infos">
                        
                        <div class="grid grid-2">
                            <div class="form-group">
                                <label class="form-label" for="prenom">Prénom</label>
                                <input type="text" id="prenom" name="prenom" class="form-control" required
                                       value="${membre.prenom}">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="nom">Nom</label>
                                <input type="text" id="nom" name="nom" class="form-control" required
                                       value="${membre.nom}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="telephone">Numéro de téléphone</label>
                            <input type="tel" id="telephone" name="telephone" class="form-control" required
                                   value="${membre.telephone}">
                        </div>

                        <div class="text-right mt-3">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check-circle-fill"></i> Enregistrer les coordonnées
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <%-- Formulaire 2 : Sécurité et Mot de passe --%>
        <div class="card">
            <div class="card-header">
                <h5><i class="bi bi-shield-lock-fill"></i> Sécurité & Mot de passe</h5>
            </div>
            <div class="card-body">
                <form method="post" action="<%= ctx %>/profil">
                    <input type="hidden" name="action" value="update-password">
                    
                    <div class="form-group">
                        <label class="form-label" for="ancienPassword">Mot de passe actuel</label>
                        <input type="password" id="ancienPassword" name="ancienPassword" class="form-control"
                               required placeholder="Saisissez votre mot de passe actuel">
                    </div>

                    <div class="grid grid-2">
                        <div class="form-group">
                            <label class="form-label" for="nouveauPassword">Nouveau mot de passe</label>
                            <input type="password" id="nouveauPassword" name="nouveauPassword" class="form-control"
                                   required minlength="6" placeholder="Minimum 6 caractères">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="confirmPassword">Confirmer le nouveau mot de passe</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                                   required minlength="6" placeholder="Confirmez le mot de passe">
                        </div>
                    </div>

                    <div class="text-right mt-3">
                        <button type="submit" class="btn btn-accent">
                            <i class="bi bi-key-fill"></i> Modifier mon mot de passe
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
