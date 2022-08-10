{{- define "poddisruptionbudget" -}}
{{- if .poddisruptionbudget.enabled }}
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
  minAvailable: {{ .poddisruptionbudget.minAvailable }}
  selector:
    matchLabels:
      {{- include "selectorLabels" . | nindent 6 }}
{{- end }}
{{- end }}