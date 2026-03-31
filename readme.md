# Cluster API template Proxmox FLATCAR

L'idée est de déployer des clusters Kubernetes avec Cluster API en mode GitOps avec ArgoCD.
Je me sers de cette chart pour appréhender le concept de CAPI.
Je partage ici, je me dis que ça peut toujours servir à quelqu'un.
Je déploie des clusters Flatcar basés sur une image buildée avec image-builder sur le provider PROXMOX.
Il y a sûrement des trucs qui marchent pas et des trucs qui servent à rien.

# Référence

https://github.com/ionos-cloud/cluster-api-provider-proxmox
https://cluster-api.sigs.k8s.io/introduction
https://image-builder.sigs.k8s.io/

## Les indispensables
### Serveur Proxmox
L'installation qui vous plaira.
https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_12_Bookworm

### Cluster existant
L'installation qui vous plaira.
https://kind.sigs.k8s.io/docs/user/quick-start/
https://docs.k3s.io/installation

### ArgoCD sur le cluster existant
https://argo-cd.readthedocs.io/en/stable/

## Installation de la chart via dependencies
```yaml
apiVersion: v2
name: capi-proxmox
version: 0.1.0
dependencies:
  - name: capi-proxmox
    version: 0.1.2
    repository: "https://simongozzo.github.io/capi-proxmox-chart"
```

## Structure du dépôt git pour déclarer les valeurs
```
➜  clusters-deploy git:(main) tree
.
├── README.md
└── clusters
    ├── dev
    │   ├── Chart.yaml
    │   ├── templates
    │   └── values.yaml
    └── internal
        ├── Chart.yaml
        ├── templates
        └── values.yaml
```

## Addons personnalisés

**Nouveauté v0.1.2** : Vous pouvez maintenant ajouter vos propres templates/addons depuis votre structure `clusters-deploy` !

### Exemple d'utilisation

Dans votre `clusters/dev/values.yaml` :

```yaml
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
        
  - name: monitoring
    data:
      prometheus.yaml: |
        # Vos manifests de monitoring
```

Les addons personnalisés seront automatiquement déployés sur le cluster via le mécanisme `ClusterResourceSet` de CAPI.

## Structure de l'ApplicationSet ArgoCD
```
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: clusters-deploy
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  syncPolicy:
    preserveResourcesOnDeletion: true
  generators:
    - git:
        repoURL: >-
          https://your-gitlab.fr/clusters-deploy.git
        revision: HEAD
        directories:
          - path: 'clusters/*'
  template:
    metadata:
      name: 'clusters-deploy-{{ .path.basenameNormalized }}'
    spec:
      project: clusters-deploy
      source:
        repoURL: >-
          https://your-gitlab.fr/clusters-deploy.git
        targetRevision: HEAD
        path: '{{ .path.path }}'
        #path: .
        helm:
          ignoreMissingValueFiles: true
          valueFiles:
            - values.yaml
      destination:
        name: in-cluster
        namespace: '{{ index .path.segments 1 }}'
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
          - CreateNamespace=true
          - ServerSideApply=true
```

## export kubeconfig
exemple :  
```
kubectl get secret k8sdev-kubeconfig \
  -n dev \
  -o jsonpath='{.data.value}' | base64 -d > ~/.kube/k8sdev.yml
```

## template PROXMOX
La dernier releases https://github.com/ionos-cloud/cluster-api-provider-proxmox ne prend pas en charge la creation de disque supplementaire pour les nodes.
donc si on veut utiliser par exemple le stockage longhorn il faut ajouter un disque supplementaire au template proxmox qui vient de image builder.  
