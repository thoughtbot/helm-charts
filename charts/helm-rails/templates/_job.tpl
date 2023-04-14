{{- define "job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
{{- if .backoffLimit }}
  backoffLimit: {{ .backoffLimit }}
{{- end }}
  template:
{{- $pod := deepCopy .pod | merge (pick . "component" "container" "containers" "csiSecrets" "http" "image" "name" "version" "Release" "Values" "command" "restartPolicy") -}}
{{- if .namespace.secretproviderclass }}
{{- $_ := set $pod "secretproviderclasses" .namespace.secretproviderclass }}
{{- end }}
{{- if .namespace.serviceaccount }}
{{- $_ := set $pod "podserviceaccounts" .namespace.serviceaccount }}
{{- end }}
{{- include "pod" $pod | nindent 4 }}
{{- end }}
