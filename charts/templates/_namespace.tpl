{{- define "namespace" -}}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .namespace.name }}
  labels:
    {{- if .Values.defaults.istioInjection }}
    istio-injection: enabled
    {{- end }}
    {{- include "labels" . | nindent 4 }}
{{- end }}
