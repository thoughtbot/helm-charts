{{- define "cronjob" -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
{{- if .backoffLimit }}
  backoffLimit: {{ .backoffLimit }}
{{- end }}
{{- if .startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ .startingDeadlineSeconds }}
{{- end }}
{{- if .concurrencyPolicy }}
  concurrencyPolicy: {{ .concurrencyPolicy }}
{{- end }}
{{- if .suspend }}
  suspend: {{ .suspend }}
{{- end }}
{{- if .successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ .successfulJobsHistoryLimit }}
{{- end }}
{{- if .failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ .failedJobsHistoryLimit }}
{{- end }}
  schedule: {{ .schedule | toYaml }}
  jobTemplate:
    metadata:
      labels:
        {{- include "labels" . | nindent 8 }}
    spec:
      template:
{{- $pod := deepCopy .pod | merge (pick . "component" "container" "containers" "csiSecrets" "http" "image" "name" "version" "Release" "Values" "command" "restartPolicy") -}}
{{- if .namespace.secretproviderclass }}
{{- $_ := set $pod "secretproviderclasses" .namespace.secretproviderclass }}
{{- end }}
{{- if .namespace.secretproviderclass }}
{{- $_ := set $pod "podserviceaccounts" .namespace.serviceaccount }}
{{- end }}
{{- include "pod" $pod | nindent 8 }}
{{- end }}
