# Cluster Api template Promox FLATCAR

L'idée est de deployer des clusters Kubenetes avec cluster API en mode gitops avec ArgoCD.   
Je me sert de cette chart pour appréhender le concepte de CAPI. 
Je partage ici, je me dis que ça peut toujours servir à quelqu'un.  
Je déploye des clusters Flatcar basé sur une image buildé avec image builder sur le provider PROXMOX. 
Il y a surement des trucs qui marche pas et des trucs qui servent à rien.  

# Référence 

https://github.com/ionos-cloud/cluster-api-provider-proxmox   
https://cluster-api.sigs.k8s.io/introduction  
https://image-builder.sigs.k8s.io/

## Les indispensables
### serveur proxmox 
L'installation qui vous plaira. 
https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_12_Bookworm  

### cluster existant
L'installation qui vous plaira. 
https://kind.sigs.k8s.io/docs/user/quick-start/
https://docs.k3s.io/installation

### ArgoCD sur le cluster de existant
https://argo-cd.readthedocs.io/en/stable/

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
## stucture de l'ApplicationSet ArgoCD
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
