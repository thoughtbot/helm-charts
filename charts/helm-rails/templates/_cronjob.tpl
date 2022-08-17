{{- define "cronjob" -}}
apiVersion: batch/v1beta1
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
