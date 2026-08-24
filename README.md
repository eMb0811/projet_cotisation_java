# 🎓 UCAD Cotisations - Système de Gestion des Cotisations & Amendes

Application Web d'Entreprise **Jakarta EE 10** conçue pour la gestion des membres, des cotisations mensuelles, des pénalités/amendes, de la génération de reçus PDF, des exports Excel et de l'envoi d'e-mails de notification pour l'**Université Cheikh Anta Diop de Dakar (UCAD)**.

---

## 📖 Documentation Complète

Pour un descriptif exhaustif de tout ce qui a été réalisé (architecture, modèle de données, fonctionnalités, inventaire des fichiers, sécurité, etc.), veuillez consulter le document :
👉 **[RAPPORT_PROJET.md](RAPPORT_PROJET.md)**

---

## ⚡ Démarrage Rapide

### Avec Docker Compose :
```bash
docker compose up --build
```
Accès : [http://localhost:8080/](http://localhost:8080/)

### Avec Maven & Tomcat 10.1+ :
```bash
mvn clean package
```
Déployez ensuite le fichier `target/cotisations-app.war` dans le répertoire `webapps/` de votre serveur Tomcat 10.1.

### 🔑 Identifiants Administrateur :
- **E-mail** : `admin@ucad.sn`
- **Mot de passe** : `admin123`
