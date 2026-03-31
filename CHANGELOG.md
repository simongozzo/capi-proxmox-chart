# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

## [0.1.4] - 2026-03-31

### Corrigé
- **existingSecret pour SSH** : Utilisation de `valueFrom.secret` au lieu de `lookup` pour compatibilité ArgoCD
  - Le `lookup` ne fonctionne pas en mode dry-run d'ArgoCD
  - Utilisation de la référence de secret native de CAPI : `valueFrom.secret.name` et `valueFrom.secret.key`
  - CAPI résoudra la référence au moment de la création de la machine
  - Correction appliquée dans [`controlplane.yaml`](charts/capi-proxmox/templates/controlplane.yaml) et [`bootstrap.yaml`](charts/capi-proxmox/templates/bootstrap.yaml)

### Note d'utilisation
Le secret doit être créé dans le namespace du cluster **avant** le déploiement :
```bash
kubectl create secret generic my-ssh-keys \
  --namespace <namespace-du-cluster> \
  --from-literal=key="ssh-ed25519 AAAAC3Nza..."
```

Puis dans `values.yaml` :
```yaml
existingSecret: "my-ssh-keys"
```

## [0.1.3] - 2026-03-31

### Corrigé
- Tentative de correction avec `lookup` (ne fonctionne pas avec ArgoCD)

## [0.1.2] - 2026-03-31

### Ajouté
- **Support des addons personnalisés** : Nouvelle fonctionnalité `customAddons` permettant d'ajouter des templates/manifests personnalisés depuis votre structure `clusters-deploy`
- Nouveau template [`addons-custom.yaml`](charts/capi-proxmox/templates/addons-custom.yaml) pour gérer les ConfigMaps personnalisés
- Fichier d'exemple [`custom-addons-example.yaml`](charts/capi-proxmox/examples/custom-addons-example.yaml) montrant comment utiliser les addons personnalisés
- Documentation enrichie dans [`README.md`](charts/capi-proxmox/README.md) et [`readme.md`](readme.md)

### Modifié
- [`values.yaml`](charts/capi-proxmox/values.yaml) : Ajout du paramètre `customAddons` avec documentation
- [`addons.yaml`](charts/capi-proxmox/templates/addons.yaml) : Mise à jour du ClusterResourceSet pour inclure les addons personnalisés
- [`cluster.yaml`](charts/capi-proxmox/templates/cluster.yaml) : Ajout du label `custom-addons: "true"` si des addons personnalisés sont définis
- [`Chart.yaml`](charts/capi-proxmox/Chart.yaml) : Version incrémentée à 0.1.2 et ajout d'une description

### Utilisation
```yaml
customAddons:
  - name: longhorn
    data:
      longhorn.yaml: |
        # Vos manifests Kubernetes ici
```

## [0.1.1] - 2026-01-29

### Modifié
- Corrections et améliorations diverses

## [0.1.0] - 2026-01-29

### Ajouté
- Version initiale de la chart
- Support de Calico, Metrics Server, Traefik
- Configuration LVM pour stockage persistant
- Autoscaling des workers
- Gestion des mises à jour
