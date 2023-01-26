{{- define "deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
  {{- if .secretproviderclasslist }}
  annotations:
    secret.reloader.stakater.com/reload: {{ join "," .secretproviderclasslist | quote }}
  {{- end }}
spec:
  {{- if and (not .autoscaling.enabled) (hasKey .autoscaling "enabled") }}
  replicas: {{ default 1 (default .replicas .autoscaling.minReplicas) }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "selectorLabels" . | nindent 6 }}
  {{- if .strategy }}
  strategy:
    type: {{ .strategy.type }}
  {{- end }}
  template:
{{- $pod := deepCopy .pod | merge (pick . "component" "container" "containers" "csiSecrets" "http" "image" "initContainers" "name" "version" "Release" "Values" "podannotations" ) -}}
{{- if .namespace.secretproviderclass }}
{{- $_ := set $pod "secretproviderclasses" .namespace.secretproviderclass }}
{{- end }}
{{- if .namespace.serviceaccount }}
{{- $_ := set $pod "podserviceaccounts" .namespace.serviceaccount }}
{{- end }}
{{- include "pod" $pod | nindent 4 }}
{{- end }}
---
