# DevOps & Cloud – Partie 5 : Cloud & Kubernetes

> **Étudiante** : Amal Jemli, Master DevOps
> **Cours** : [Teknolabs – DevOps & Cloud](https://docs.teknolabs.net/courses/devops-cloud/partie-5-cloud-kubernetes/)
> Suite de [devops-partie3](https://github.com/Amal356/devops-partie3) et [devops-partie4](https://github.com/Amal356/devops-partie4).

| TP | Sujet | Dossier | État |
|---|---|---|---|
| TP13 | Cloud local (Floci), AWS CLI, SDK, Terraform : module, state distant verrouillé, environnements, Trivy IaC, OpenTofu | [tp13/](tp13/README.md) | ✅ 8/8 captures |
| TP14 | Kubernetes avec K3s | `tp14/` | ⏳ en cours |
| TP15 | Helm et Kustomize | `tp15/` | ⏳ à venir |

## Fil rouge sécurité
- Aucun identifiant cloud réel : émulateur local, identifiants factices.
- Secrets hors du dépôt, variables `sensitive`, **state et kubeconfig jamais commités** (voir `.gitignore`).
- Scans bloquants en CI (Trivy IaC), versions des providers figées.
