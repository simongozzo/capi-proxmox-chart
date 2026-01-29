# Cluster Api template Promox. 

L'idée est de deployer des clusters Kubenetes avec cluster API en mode gitops avec ArgoCD

# Référence 

https://github.com/ionos-cloud/cluster-api-provider-proxmox   
https://cluster-api.sigs.k8s.io/introduction

## installation chart via dependencies
```
apiVersion: v2
name: capi-proxmox
version: 0.1.0
dependencies:
  - name: capi-proxmox
    version: 0.1.0
    repository: "https://simongozzo.github.io/capi-proxmox-chart
```
## structure du depot git declarer les valeurs
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
## stucture de l'ApplicationSet
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