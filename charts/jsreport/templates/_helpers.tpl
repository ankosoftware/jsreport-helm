{{/*
Expand the name of the chart.
*/}}
{{- define "jsreport.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jsreport.fullname" -}}
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
{{- define "jsreport.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jsreport.labels" -}}
helm.sh/chart: {{ include "jsreport.chart" . }}
{{ include "jsreport.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jsreport.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jsreport.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "jsreport.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jsreport.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the admin password and cookie secret.
Fails when neither an existing Secret nor inline credentials are provided.
*/}}
{{- define "jsreport.authSecretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- $_ := required "auth.adminPassword is required (or set auth.existingSecret)" .Values.auth.adminPassword }}
{{- $_ := required "auth.cookieSecret is required (or set auth.existingSecret)" .Values.auth.cookieSecret }}
{{- include "jsreport.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the PersistentVolumeClaim used for /app/data.
*/}}
{{- define "jsreport.dataClaimName" -}}
{{- default (printf "%s-data" (include "jsreport.fullname" .)) .Values.persistence.existingClaim }}
{{- end }}
