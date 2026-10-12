<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    </div><!-- /.page-body -->
    
    <!-- Pied de page institutionnel -->
    <footer style="margin-top:auto;padding:24px 28px;border-top:1px solid #e2e8f0;background:#ffffff;color:#64748b;font-size:12.5px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px">
        <div style="display:flex;align-items:center;gap:10px">
            <span style="font-weight:600;color:#0f172a">Universit&#233; Cheikh Anta Diop de Dakar</span>
            <span style="color:#cbd5e1">|</span>
            <span>Syst&#232;me de Gestion des Cotisations &amp; Amendes</span>
        </div>
        <div style="display:flex;align-items:center;gap:16px">
            <span style="color:#94a3b8">&copy; <%= java.time.Year.now().getValue() %> UCAD. Tous droits r&#233;serv&#233;s.</span>
            <span style="background:#f1f5f9;color:#475569;padding:3px 8px;border-radius:6px;font-weight:600;font-size:11px">v1.0.0</span>
        </div>
    </footer>
</div><!-- /.main-content -->

<script>
    // Toggle menu mobile pour admin
    function toggleMobileSidebar() {
        const sidebar = document.getElementById('adminSidebar');
        const overlay = document.getElementById('sidebarOverlay');
        if (sidebar) {
            sidebar.classList.toggle('mobile-open');
        }
    }

    // Auto-dismiss alerts after 5 seconds
    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(a => {
            a.style.transition = 'opacity 0.5s';
            a.style.opacity = '0';
            setTimeout(() => a.remove(), 500);
        });
    }, 5000);
</script>
</body>
</html>