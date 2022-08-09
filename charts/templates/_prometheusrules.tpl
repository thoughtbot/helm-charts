{{- define "prometheusrules" -}}
{{- if .prometheusservicelevel.enabled -}}
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: {{ $.Release.Name }}-{{ .namespace.name }}-slos
  labels:
    {{- include "labels" . | nindent 4 }}
    prometheus: flightdeck-prometheus
  namespace: {{ .namespace.name }}
spec:
  service: "{{ $.Release.Name }}-{{ .namespace.name }}-web"
  labels:
    owner: {{ $.Release.Name | quote}}
  slos:
  - name: "{{ $.Release.Name }}-{{ .namespace.name }}-web-requests-availability"
    objective: 99.9
    description: "Common SLO based on availability for HTTP request responses to the web app"
    sli:
      events:
        errorQuery: sum(rate(istio_requests_total{destination_service_name={{ include "fullname" . | quote }},destination_service_namespace={{ .namespace.name | quote }},response_code=~"(5..|429)"}[{{ "{{.window}}" }}]))
        totalQuery: sum(rate(istio_requests_total{destination_service_name={{ include "fullname" . | quote }},destination_service_namespace={{ .namespace.name | quote }}}[{{ "{{.window}}" }}])) > 0
    alerting:
      pageAlert:
        disable: true
      ticketAlert:
        disable: true
---
{{- end }}
{{- end }}
