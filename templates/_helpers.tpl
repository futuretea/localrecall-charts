{{/*
Expand the name of the chart.
*/}}
{{- define "localrecall.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "localrecall.fullname" -}}
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
{{- define "localrecall.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "localrecall.labels" -}}
helm.sh/chart: {{ include "localrecall.chart" . }}
{{ include "localrecall.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "localrecall.selectorLabels" -}}
app.kubernetes.io/name: {{ include "localrecall.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "localrecall.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "localrecall.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper LocalRecall image name
*/}}
{{- define "localrecall.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else }}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL connection URL
*/}}
{{- define "localrecall.databaseUrl" -}}
{{- $host := .Values.postgresql.external.host -}}
{{- $port := .Values.postgresql.external.port | int -}}
{{- $database := .Values.postgresql.external.database -}}
{{- $username := .Values.postgresql.external.username -}}
{{- $password := .Values.postgresql.external.password -}}
{{- $sslMode := .Values.postgresql.external.sslMode -}}
{{- printf "postgresql://%s:%s@%s:%d/%s?sslmode=%s" $username $password $host $port $database $sslMode -}}
{{- end }}
