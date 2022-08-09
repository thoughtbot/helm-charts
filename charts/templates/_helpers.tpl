{{- define "appname" -}}
{{   default .Release.Name .Values.app.name }}
{{- end }}

{{- define "component" -}}
{{-   if .component }}
{{-     printf "%s-%s" (include "appname" .) .component }}
{{-   else }}
{{-     include "appname" . }}
{{-   end }}
{{- end }}

{{- define "fullreleasename" -}}
{{-   if .Values.app.name -}}
{{-     if contains .Values.app.name .Release.Name }}
{{-       .Release.Name | trunc 63 | trimSuffix "-" }}
{{-     else }}
{{-       printf "%s-%s" .Values.app.name .Release.Name | trunc 63 | trimSuffix "-" }}
{{-     end }}
{{-   else }}
{{-     .Release.Name | trunc 63 | trimSuffix "-" }}
{{-   end }}
{{- end }}

{{- define "defaultfullname" -}}
{{-   if .component -}}
{{-     printf "%s-%s" (include "fullreleasename" .) .component | trunc 63 | trimSuffix "-" }}
{{-   else }}
{{-     include "fullreleasename" . }}
{{-   end }}
{{- end }}

{{- define "fullname" -}}
{{-   if .fullnameOverride }}
{{-     .fullnameOverride | trunc 63 | trimSuffix "-" }}
{{-   else }}
{{-     include "defaultfullname" . }}
{{-   end }}
{{- end }}

{{- define "labels" -}}
{{ include "selectorLabels" . }}
{{- if .Values.app.version }}
app.kubernetes.io/version: {{ .Values.app.version | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
initiator: githubActions
{{- end }}

{{- define "selectorLabels" -}}
{{- with .component -}}
app.kubernetes.io/component: {{ . }}
{{ end -}}
app.kubernetes.io/instance: {{ default .Release.Name .Values.app.instance }}
app.kubernetes.io/name: {{ include "appname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
