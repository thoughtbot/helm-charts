{{- define "servicemonitor" -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
    prometheus: flightdeck-prometheus
spec:
  endpoints:
  - port: metrics
  selector:
    matchLabels:
      {{- include "selectorLabels" . | nindent 6 }}
{{- end -}}