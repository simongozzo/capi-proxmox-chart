# capi-proxmox Chart

Chart Helm pour déployer des clusters Kubernetes avec Cluster API sur Proxmox.

## Fonctionnalités

- Déploiement de clusters K8s via CAPI sur Proxmox
- Support des addons intégrés (Calico, Metrics Server, Traefik)
- **Support des addons personnalisés** via `customAddons`
- Autoscaling des workers
- Configuration LVM pour stockage persistant
- Gestion des mises à jour

## Addons personnalisés

Vous pouvez maintenant ajouter vos propres addons en utilisant le paramètre `customAddons` dans votre `values.yaml`.

### Exemple d'utilisation

Dans votre structure `clusters-deploy`, créez un fichier `values.yaml` :

```yaml
# clusters/dev/values.yaml
clusterName: k8sdev
# ... autres configurations ...

# Addons personnalisés
customAddons:
  - name: longhorn
    data:
      longhorn.yaml: |
        apiVersion: v1
        kind: Namespace
        metadata:
          name: longhorn-system
        ---
        # Votre manifest Longhorn complet ici
        
  - name: cert-manager
    data:
      cert-manager.yaml: |
        apiVersion: v1
        kind: Namespace
        metadata:
          name: cert-manager
        ---
        # Votre manifest cert-manager complet ici
```

### Comment ça fonctionne

1. Chaque addon personnalisé crée un `ConfigMap` dans le namespace du cluster
2. Le `ClusterResourceSet` référence automatiquement ces ConfigMaps
3. Les manifests sont appliqués sur le cluster cible lors de sa création

### Structure des customAddons

```yaml
customAddons:
  - name: <nom-de-l-addon>        # Nom unique pour l'addon
    data:
      <fichier>.yaml: |            # Nom du fichier dans le ConfigMap
        # Vos manifests Kubernetes ici
```

## Rollout Strategy

Pour que la stratégie de rollout "rollingUpdate" fonctionne, il faut utiliser des variables sur les templates et infrastructure avec un hash : `{{ include "machineTemplateHash" . }}` (voir `_helpers.tpl`)

