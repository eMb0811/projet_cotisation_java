# 🏛️ Plateforme de Gestion des Cotisations — UCAD

### Déploiement Cloud-Native Multi-Nœuds avec Kubernetes (K3s), Terraform, Ansible & CI/CD DevSecOps sur AWS

![Java](https://img.shields.io/badge/Java-17%20Temurin-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-F05032?style=for-the-badge&logo=java&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20ECR%20%7C%20VPC-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)

---

## 📌 Présentation du Projet

Application web d'entreprise conçue sous **Jakarta EE 10** pour l'Université Cheikh Anta Diop de Dakar (UCAD). Elle assure la gestion des membres, des cotisations mensuelles, le calcul des pénalités, la génération automatique de reçus PDF, l'export Excel et les notifications par e-mail.

Ce projet implémente une chaîne complète d'ingénierie Cloud et DevSecOps :
- **Infrastructure as Code (IaC)** avec Terraform.
- **Gestion de configuration et automatisation** avec Ansible.
- **Orchestration de conteneurs** avec Kubernetes (distribution K3s).
- **Intégration et Déploiement Continus (CI/CD)** avec GitHub Actions et Amazon ECR.
- **Base de données relationnelle dédiée** avec PostgreSQL 16 isolée en réseau privé.

---

## 🏗️ Architecture Technique Multi-Nœuds

```plaintext
[ Utilisateur / Recruteur ]
            │
            ▼ (Port 30080 HTTP / 22 SSH)
┌───────────────────────────────────────────┴───────────────────────────────────────────┐
│ AWS VPC Dédié (10.0.0.0/16)                                                           │
│                                                                                       │
│  ┌────────────────────────────────────────┐   ┌────────────────────────────────┐      │
│  │ Nœud Applicatif (EC2 K3s)              │   │ Nœud Base de Données (EC2)     │      │
│  │                                        │   │                                │      │
│  │ • Cluster Kubernetes (K3s Server)      │   │ • PostgreSQL 16                │      │
│  │ • Service NodePort : 30080             │   │ • Base : cotisations_db        │      │
│  │ • Déploiement : 2 Pods (RollingUpdate) │   │ • Écoute : 10.0.1.42:5432      │      │
│  │ • Conteneurs : Tomcat 10.1 (JakartaEE) │   │ • Authentification : md5       │      │
│  │ • Mémoire : 1 Go RAM + 2 Go Swap       │   │                                │      │
│  └───────────────────┬────────────────────┘   └────────────────┬───────────────┘      │
│                      │                                         │                      │
│                      └────────(Port 5432 - Trafic Privé)───────┘                      │
└───────────────────────────────────────────────────────────────────────────────────────┘
                                           ▲
                                           │ Images Docker privées
                               ┌───────────┴───────────┐
                               │ Amazon ECR (Registry) │
                               │ ucad-cotisations-app  │
                               └───────────▲───────────┘
                                           │ Push sécurisé
                               ┌───────────┴───────────┐
                               │ GitHub Actions (CI/CD)│
                               │ • Compilation Maven   │
                               │ • Build Multi-Stage   │
                               │ • Audit Trivy         │
                               │ • Déploiement K8s     │
                               └───────────────────────┘
```

---

## 🛠️ Stack Technologique & Outils

| Composant | Technologie | Rôle dans le projet |
| :--- | :--- | :--- |
| **Langage & Framework** | Java 17, Jakarta EE 10, JPA / Hibernate | Cœur de l'application métier et persistance des données. |
| **Serveur d'application** | Apache Tomcat 10.1 | Runtime pour servlets et services web. |
| **Base de données** | PostgreSQL 16 | Serveur de persistance dédié, sécurisé sur sous-réseau privé. |
| **Conteneurisation** | Docker | Packaging d'images multi-stage légères et optimisées. |
| **Sécurité (Shift-Left)** | Trivy | Audit des vulnérabilités des conteneurs, dépendances et IaC. |
| **Infrastructure (IaC)** | Terraform | Provisioning reproductible du réseau AWS (VPC, Subnets, SG) et des VM EC2. |
| **Automatisation** | Ansible | Déploiement automatisé et configuration de PostgreSQL et du cluster K3s. |
| **Orchestration** | Kubernetes (K3s) | Gestion de la haute disponibilité, rolling updates et exposition des services. |
| **Registre Cloud** | Amazon ECR | Stockage privé, versionné et sécurisé des images de production. |
| **Pipeline CI/CD** | GitHub Actions | Automatisation complète du build au déploiement sans intervention manuelle. |

---

## 📁 Arborescence du Dépôt

```plaintext
projet_cotisation_java/
├── .github/
│   └── workflows/
│       └── devsecops-k8s.yml    # Pipeline CI/CD GitHub Actions
├── k8s/
│   ├── configmap.yaml           # Configuration non sensible (URL DB, Timezone)
│   ├── secret.yaml              # Identifiants chiffrés de la base
│   ├── deployment.yaml          # Spécification des Pods et politique de RollingUpdate
│   └── service.yaml             # Exposition réseau NodePort (30080)
├── terraform/
│   ├── main.tf                  # Définition de l'infrastructure AWS (VPC, EC2, SG)
│   ├── variables.tf             # Paramètres région et clés SSH
│   └── outputs.tf               # Export automatique des adresses IP
├── ansible/
│   ├── inventory.ini            # Inventaire des nœuds K8s et DB
│   └── playbook.yml             # Rôles d'installation PostgreSQL et bootstrapping K3s
├── src/                         # Code source Java Jakarta EE 10
├── pom.xml                      # Dépendances Maven (PostgreSQL Driver, Jakarta EE)
├── Dockerfile                   # Build multi-stage optimisé (Maven ➔ Tomcat 10)
└── README.md
```

---

## 🚀 Guide de Déploiement Pas à Pas

### 1. Provisionner l'infrastructure Cloud avec Terraform

```bash
cd terraform/
terraform init
terraform apply -var="key_name=votre-cle-aws"
```

### 2. Configurer les serveurs avec Ansible

Mettez à jour les adresses IP dans `ansible/inventory.ini`, puis lancez :

```bash
cd ../ansible/
ansible-playbook -i inventory.ini playbook.yml
```

### 3. Activer les manifestes sur le cluster Kubernetes

```bash
# Sur le serveur K3s :
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/deployment.yaml
```

### 4. Automatisation via GitHub Actions

Chaque `git push` sur la branche `main` déclenche :
1. Le packaging du fichier `.war` par Maven.
2. La construction de l'image Docker.
3. Le push vers Amazon ECR.
4. L'exécution de `kubectl set image` sur le cluster K3s pour une mise à jour transparente sans indisponibilité (**Zero-Downtime**).

---

## 🔒 Bonnes Pratiques de Sécurité Appliquées

- **Isolation réseau stricte** : Le serveur PostgreSQL n'écoute que sur les adresses privées du VPC (`10.0.0.0/16`) et refuse toute connexion directe depuis Internet.
- **Séparation des configurations** : Aucune information sensible n'est écrite en dur dans le code ; utilisation des `Secret` et `ConfigMap` natifs de Kubernetes.
- **Gestion de la mémoire sur EC2** : Mise en place d'un espace de swap de 2 Go sous Linux pour prémunir les instances `t3.micro` contre les saturations mémoires (OOM).
- **Mises à jour sans coupure** : Stratégie `RollingUpdate` avec sondes `readinessProbe` et `livenessProbe` pour garantir la continuité de service aux utilisateurs de l'UCAD.

---

## 👤 Auteur & Contact

**Barry Mouhamet (El Hadji Mouhamed Barry)**  
*Étudiant en Master 1 Réseaux et Télécommunications (RETEL) — Université Cheikh Anta Diop (UCAD / FST), Dakar.*  
- **Spécialité** : Cloud Computing, DevOps & DevSecOps, Cybersécurité  
- **GitHub** : [@eMb0811](https://github.com/eMb0811)  
- **Localisation** : Dakar, Sénégal
