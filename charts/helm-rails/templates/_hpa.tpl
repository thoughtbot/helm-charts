{{- define "hpa" -}}
{{- if .autoscaling.enabled -}}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "fullname" . }}
{{- with .autoscaling }}
  minReplicas: {{ .minReplicas }}
  maxReplicas: {{ .maxReplicas }}
{{- with .metrics }}
  metrics:
{{- range . }}
{{- if .object }}
  - object:
      {{ omit .object "describedObject" | toYaml | nindent 6 | trim }}
      describedObject:
        {{ .object.describedObject | toYaml | nindent 8 | trim }}
        {{- if not .object.describedObject.name }}
        name: {{ include "fullname" $ }}
        {{- end }}
    {{ omit . "object" | toYaml | nindent 4 | trim }}
{{- else }}
  - {{ . | toYaml | nindent 4 | trim }}
{{- end }}
{{- end }}
{{- end -}}
{{- with .behavior }}
  behavior:
    {{ . | toYaml | nindent 4 | trim }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
