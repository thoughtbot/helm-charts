{{- define "prometheusservicelevel" -}}
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
  - name: "{{ $.Release.Name }}-{{ .namespace.name }}-requests-99-latency"
    objective: 99
    description: "Common SLO based on latency for HTTP request responses"
    sli:
      events:
        errorQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" . | quote }}}[5m])))[{{.window}}:5m]) - sum_over_time((sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name={{ include "fullname" . | quote }},le="1500"}[5m])))[{{.window}}:5m])
        totalQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" . | quote }}}[5m])))[{{.window}}:5m]) > 0
    alerting:
      name: AdminLatency99th
      labels:
        category: "latency"
      annotations:
        summary: "High latency on requests responses"
      pageAlert:
        disable: true
      ticketAlert:
        disable: true
  - name: "{{ $.Release.Name }}-{{ .namespace.name }}-requests-95-latency"
    objective: 95
    description: "Common SLO based on latency for HTTP request responses"
    sli:
      events:
        errorQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" . | quote }}}[5m])))[{{.window}}:5m]) - sum_over_time((sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name={{ include "fullname" . | quote }},le="750"}[5m])))[{{.window}}:5m])
        totalQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" . | quote }}}[5m])))[{{.window}}:5m]) > 0
    alerting:
      name: HTTPLatency95th
      labels:
        category: "latency"
      annotations:
        summary: "High latency on requests responses"
      pageAlert:
        disable: true
      ticketAlert:
        disable: true
---
{{- end }}
{{- end }}
