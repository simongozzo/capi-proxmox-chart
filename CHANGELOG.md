# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

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
