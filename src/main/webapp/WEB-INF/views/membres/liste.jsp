<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("pageTitle", "Gestion des Membres");
    request.setAttribute("activePage", "membres");
    String ctx = request.getContextPath();
    String devise = sn.ucad.cotisations.config.AppConfig.getInstance().getDevise();
    boolean isAdmin = "ADMIN".equals(session.getAttribute("sessionRole"));
%>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4" style="flex-wrap:wrap;gap:12px">
    <div>
        <h2 style="font-size:20px;font-weight:700;color:var(--text-main)">Répertoire des membres</h2>
        <p class="text-muted">${membres.size()} membre(s) enregistré(s)</p>
    </div>
    <div class="d-flex gap-2">
        <% if (isAdmin) { %>
        <a href="<%= ctx %>/membres?action=excel" class="btn btn-outline btn-sm">
            <i class="bi bi-file-earmark-excel-fill" style="color:#059669"></i> Exporter Excel
        </a>
        <a href="<%= ctx %>/membres?action=nouveau" class="btn btn-primary btn-sm">
            <i class="bi bi-person-plus-fill"></i> Nouveau membre
        </a>
        <% } %>
    </div>
</div>

<%-- Barre de recherche instantanée --%>
<div class="card mb-4">
    <div class="card-body" style="padding:12px 18px">
        <div style="position:relative">
            <i class="bi bi-search" style="position:absolute;left:14px;top:50%;transform:translateY(-50%);color:#94a3b8"></i>
            <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Rechercher par nom, prénom, email ou téléphone..." 
                   class="form-control" style="padding-left:40px;border-radius:8px">
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body" style="padding:0">
        <div class="table-container">
            <table id="membresTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Nom complet</th>
                        <th>Email</th>
                        <th>Téléphone</th>
                        <th>Date d'adhésion</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="m" items="${membres}" varStatus="s">
                    <tr>
                        <td class="text-muted">${s.index + 1}</td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px">
                                <div style="width:34px;height:34px;background:var(--brand-primary);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:13px;font-weight:700;flex-shrink:0">
                                    ${m.prenom.charAt(0)}
                                </div>
                                <div>
                                    <div style="font-weight:600;color:var(--text-main)">${m.nomComplet}</div>
                                </div>
                            </div>
                        </td>
                        <td>${m.utilisateur.email}</td>
                        <td>${m.telephone}</td>
                        <td class="text-muted">${m.dateAdhesion}</td>
                        <td>
                            <c:choose>
                                <c:when test="${m.statut.name() == 'ACTIF'}"><span class="badge badge-success"><i class="bi bi-check-circle-fill"></i> Actif</span></c:when>
                                <c:when test="${m.statut.name() == 'SUSPENDU'}"><span class="badge badge-warning"><i class="bi bi-pause-circle-fill"></i> Suspendu</span></c:when>
                                <c:otherwise><span class="badge badge-muted"><i class="bi bi-x-circle-fill"></i> Inactif</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px">
                                <a href="<%= ctx %>/membres?action=detail&id=${m.id}" class="btn btn-outline btn-sm" title="Consulter la fiche"><i class="bi bi-eye-fill"></i></a>
                                <% if (isAdmin) { %>
                                <a href="<%= ctx %>/membres?action=modifier&id=${m.id}" class="btn btn-primary btn-sm" title="Modifier"><i class="bi bi-pencil-fill"></i></a>
                                <c:if test="${m.statut.name() == 'ACTIF'}">
                                    <form method="post" action="<%= ctx %>/membres" style="display:inline"
                                          onsubmit="return confirm('Désactiver temporairement ce membre ?')">
                                        <input type="hidden" name="action" value="desactiver">
                                        <input type="hidden" name="id" value="${m.id}">
                                        <button type="submit" class="btn btn-outline btn-sm" title="Désactiver" style="color:#d97706;border-color:#fde68a"><i class="bi bi-pause-circle-fill"></i></button>
                                    </form>
                                </c:if>
                                <form method="post" action="<%= ctx %>/membres" style="display:inline"
                                      onsubmit="return confirm('⚠️ ATTENTION : Êtes-vous sûr de vouloir SUPPRIMER DÉFINITIVEMENT ce membre de la base de données ? Toutes ses cotisations et amendes associées seront également effacées.')">
                                    <input type="hidden" name="action" value="supprimer">
                                    <input type="hidden" name="id" value="${m.id}">
                                    <button type="submit" class="btn btn-danger btn-sm" title="Supprimer définitivement de la base de données"><i class="bi bi-trash-fill"></i></button>
                                </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty membres}">
                    <tr><td colspan="7" class="text-center" style="padding:48px">
                        <i class="bi bi-people" style="font-size:40px;color:#cbd5e1;display:block;margin-bottom:8px"></i>
                        <span class="text-muted">Aucun membre enregistré</span>
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function filterTable() {
    var input = document.getElementById("searchInput");
    var filter = input.value.toLowerCase();
    var table = document.getElementById("membresTable");
    var tr = table.getElementsByTagName("tr");

    for (var i = 1; i < tr.length; i++) {
        var rowText = tr[i].textContent || tr[i].innerText;
        if (rowText.toLowerCase().indexOf(filter) > -1) {
            tr[i].style.display = "";
        } else {
            tr[i].style.display = "none";
        }
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
