<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    sn.ucad.cotisations.model.Membre membre = (sn.ucad.cotisations.model.Membre) request.getAttribute("membre");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
    String titre = (membre != null && membre.getId() != null) ? "Modifier le membre" : "Nouveau membre";
    request.setAttribute("pageTitle", titre);
    request.setAttribute("activePage", "membres");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex align-items-center gap-3 mb-4">
    <a href="<%= ctx %>/membres" class="btn btn-outline btn-sm"><i class="bi bi-arrow-left"></i> Retour</a>
    <h2 style="font-size:20px;font-weight:700;color:var(--text-main)"><%= titre %></h2>
</div>

<% String error = (String) request.getAttribute("error"); %>
<% if (error != null) { %>
<div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> <%= error %></div>
<% } %>

<div class="card" style="max-width:640px">
    <div class="card-header">
        <h5><i class="bi bi-person-fill"></i> Informations du membre</h5>
    </div>
    <div class="card-body">
        <form method="post" action="<%= ctx %>/membres">
            <c:if test="${membre != null && membre.id != null}">
                <input type="hidden" name="action" value="modifier">
                <input type="hidden" name="id" value="${membre.id}">
            </c:if>
            <c:if test="${membre == null || membre.id == null}">
                <input type="hidden" name="action" value="creer">
            </c:if>

            <div class="grid grid-2">
                <div class="form-group">
                    <label class="form-label" for="nom">Nom <span style="color:red">*</span></label>
                    <input type="text" id="nom" name="nom" class="form-control" required
                           value="${membre != null ? membre.nom : ''}" placeholder="DIOP">
                </div>
                <div class="form-group">
                    <label class="form-label" for="prenom">Prénom <span style="color:red">*</span></label>
                    <input type="text" id="prenom" name="prenom" class="form-control" required
                           value="${membre != null ? membre.prenom : ''}" placeholder="Amadou">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="telephone">Téléphone <span style="color:red">*</span></label>
                <input type="tel" id="telephone" name="telephone" class="form-control" required
                       value="${membre != null ? membre.telephone : ''}" placeholder="+221770000000">
            </div>

            <c:if test="${membre == null || membre.id == null}">
                <div class="form-group">
                    <label class="form-label" for="email">Email <span style="color:red">*</span></label>
                    <input type="email" id="email" name="email" class="form-control" required placeholder="prenom.nom@ucad.sn">
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">Mot de passe <span style="color:red">*</span></label>
                    <input type="password" id="password" name="password" class="form-control" required placeholder="Minimum 6 caractères" minlength="6">
                </div>
                <div class="form-group">
                    <label class="form-label" for="dateAdhesion">Date d'adhésion</label>
                    <input type="date" id="dateAdhesion" name="dateAdhesion" class="form-control"
                           value="<%= java.time.LocalDate.now().toString() %>">
                </div>
            </c:if>

            <c:if test="${membre != null && membre.id != null}">
                <div class="form-group">
                    <label class="form-label" for="statut">Statut</label>
                    <select id="statut" name="statut" class="form-control">
                        <c:forEach var="s" items="${statuts}">
                            <option value="${s}" <c:if test="${membre.statut == s}">selected</c:if>>${s}</option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>

            <div class="d-flex gap-2 mt-3">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg"></i>
                    <c:choose>
                        <c:when test="${membre != null && membre.id != null}">Enregistrer les modifications</c:when>
                        <c:otherwise>Créer le membre</c:otherwise>
                    </c:choose>
                </button>
                <a href="<%= ctx %>/membres" class="btn btn-outline">Annuler</a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
