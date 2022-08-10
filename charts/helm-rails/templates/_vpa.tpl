{{- define "vpa" -}}
{{- if .autosizing.enabled -}}
---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "fullname" . }}
  updatePolicy:
    updateMode: {{ default "Auto" .autosizing.updatePolicy.updateMode }}
  resourcePolicy:
    containerPolicies:
{{- with .autosizing.resourcePolicy -}}
      {{ .autosizing.resourcePolicy.containerPolicies | toYaml | nindent 6 | trim }}
{{- end -}}
{{- range $key, $container := .containers }}
{{- with $container.containersizing }}
      - containerName: {{ default $key $container.name }}
{{- with $container.containersizing.maxAllowed }}
        maxAllowed:
          {{ . | toYaml | nindent 10 | trim }}
{{- end -}}
{{- with $container.containersizing.minAllowed }}
        minAllowed:
          {{ . | toYaml | nindent 10 | trim }}
{{- end -}}
{{- end -}}
{{- end -}}
{{ end -}}
{{- end -}}
