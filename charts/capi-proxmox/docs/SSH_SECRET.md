# Configuration SSH avec existingSecret

Ce guide explique comment utiliser un secret Kubernetes existant pour les clés SSH au lieu de les déclarer directement dans `values.yaml`.

## Pourquoi utiliser existingSecret ?

- **Sécurité** : Les clés SSH ne sont pas stockées en clair dans votre dépôt Git
- **Gestion centralisée** : Un seul secret peut être utilisé pour plusieurs clusters
- **Conformité** : Respecte les bonnes pratiques de gestion des secrets

## Prérequis

Le secret doit être créé **avant** le déploiement du cluster dans le **namespace du cluster**.

## Étapes

### 1. Créer le secret

```bash
# Créer le secret dans le namespace du cluster
kubectl create secret generic my-ssh-keys \
  --namespace dev \
  --from-literal=key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExample... user@host"
```

**Important** : 
- Le secret doit contenir une clé nommée `key`
- La valeur doit être votre clé SSH publique complète
- Le namespace doit correspondre au namespace où sera déployé le cluster

### 2. Vérifier le secret

```bash
kubectl get secret my-ssh-keys -n dev
kubectl get secret my-ssh-keys -n dev -o jsonpath='{.data.key}' | base64 -d
```

### 3. Configurer values.yaml

Dans votre `clusters/dev/values.yaml` :

```yaml
clusterName: k8sdev
namespace: dev

# NE PAS définir vmSshKeys
# vmSshKeys: []

# Référencer le secret existant
existingSecret: "my-ssh-keys"

# ... reste de la configuration
```

## Ordre de priorité

La chart utilise cet ordre de priorité :

1. **vmSshKeys** : Si défini (même vide `[]`), il sera utilisé
2. **existingSecret** : Si `vmSshKeys` n'est pas défini et `existingSecret` est spécifié
3. **Aucune clé** : Si aucun des deux n'est défini

## Exemple complet avec ArgoCD

### Structure du dépôt

```
clusters-deploy/
├── clusters/
│   └── dev/
│       ├── Chart.yaml
│       └── values.yaml
└── secrets/
    └── create-ssh-secrets.sh
```

### Script de création des secrets

`secrets/create-ssh-secrets.sh` :

```bash
#!/bin/bash

# Créer les secrets pour chaque environnement
kubectl create secret generic cluster-ssh-keys \
  --namespace dev \
  --from-literal=key="$(cat ~/.ssh/id_ed25519.pub)" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic cluster-ssh-keys \
  --namespace prod \
  --from-literal=key="$(cat ~/.ssh/id_ed25519.pub)" \
  --dry-run=client -o yaml | kubectl apply -f -
```

### values.yaml

```yaml
clusterName: k8sdev
namespace: dev

# Configuration réseau
controlPlaneEndpointIP: "10.10.10.100"
gateway: "10.10.10.254"

# SSH via secret
existingSecret: "cluster-ssh-keys"

# Reste de la configuration...
```

## Dépannage

### Le secret n'est pas trouvé

Si vous voyez ce message dans les manifests générés :
```yaml
# Secret my-ssh-keys not found or not yet created
```

**Solutions** :
1. Vérifiez que le secret existe : `kubectl get secret my-ssh-keys -n <namespace>`
2. Vérifiez le namespace : il doit correspondre au namespace du cluster
3. Créez le secret avant de déployer la chart

### La clé SSH ne fonctionne pas

1. Vérifiez le format de la clé :
   ```bash
   kubectl get secret my-ssh-keys -n dev -o jsonpath='{.data.key}' | base64 -d
   ```

2. La clé doit être au format :
   ```
   ssh-ed25519 AAAAC3Nza... user@host
   ```

3. Testez la clé manuellement sur une VM Proxmox

## Migration depuis vmSshKeys

Si vous utilisez actuellement `vmSshKeys` et souhaitez migrer vers `existingSecret` :

1. Créez le secret avec votre clé actuelle
2. Dans `values.yaml`, commentez ou supprimez `vmSshKeys`
3. Ajoutez `existingSecret: "nom-du-secret"`
4. Redéployez le cluster

**Note** : Pour les clusters existants, cette modification ne mettra pas à jour les clés SSH des machines déjà créées.
