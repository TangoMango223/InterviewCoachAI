{{/*
_helpers.tpl - Reusable template functions for consistency across all resources
These are like utility functions that other templates can call
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "interviewcoach.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "interviewcoach.fullname" -}}
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
{{- define "interviewcoach.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels - applied to all resources
*/}}
{{- define "interviewcoach.labels" -}}
helm.sh/chart: {{ include "interviewcoach.chart" . }}
{{ include "interviewcoach.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels - used to identify pods
*/}}
{{- define "interviewcoach.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interviewcoach.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
