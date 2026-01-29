{{/*
Expand the name of the chart.
*/}}
{{- define "capi-proxmox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "capi-proxmox.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "capi-proxmox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "capi-proxmox.labels" -}}
helm.sh/chart: {{ include "capi-proxmox.chart" . }}
{{ include "capi-proxmox.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "capi-proxmox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "capi-proxmox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "capi-proxmox.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "capi-proxmox.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "cluster-api-repo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Namespace du cluster (piloté par ArgoCD)
*/}}
{{- define "cluster.namespace" -}}
{{- .Values.namespace | default .Release.Namespace -}}
{{- end -}}

{{/*
Calcule la taille du boot volume worker
root + partsize (+ margin)
*/}}
{{- define "nodes.bootVolumeSizeWorkers" -}}
{{- $root := .Values.lvm.root | int -}}
{{- $margin := .Values.lvm.diskMargin | default 15 | int -}}
{{- if .Values.lvm.enabled -}}
  {{- $part := .Values.lvm.partsize | int -}}
  {{- add $root $part $margin -}}
{{- else -}}
  {{- add $root $margin -}}
{{- end -}}
{{- end -}}

{{/*
Convertit un chemin système en nom d'unité systemd mount
Exemple: /var/lib/longhorn -> var-lib-longhorn.mount
Usage: {{ include "pathToMountUnit" . }}
*/}}
{{- define "pathToMountUnit" -}}
{{- $path := . -}}
{{- $path = trimPrefix "/" $path -}}
{{- $path = replace "/" "-" $path -}}
{{- printf "%s.mount" $path -}}
{{- end -}}

{{/*
Hash pour mettre a jour les templates et renew les machines avec les nouvelles valeurs
*/}}
{{- define "machineTemplatePlanHash" -}}
{{- printf "%s-%d-%d" .Values.bootVolumeDevice .Values.bootVolumeSize .Values.memoryMiB | sha256sum | trunc 8 -}}
{{- end -}}

{{- define "machineTemplateHash" -}}
{{- printf "%s-%d-%d" .Values.bootVolumeDevice .Values.bootVolumeSizeWorkers .Values.memoryMiBWorkers | sha256sum | trunc 8 -}}
{{- end -}}