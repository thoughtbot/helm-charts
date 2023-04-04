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
    objective: {{ .prometheusservicelevel.availability.objective }}
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
{{- range $slo := .prometheusservicelevel.latency }}
{{- $_ := set $slo "Release" $.Release }}
{{- $_ := set $slo "Values" (deepCopy $.Values) }}
  - name: "{{ $.Release.Name }}-{{ $.namespace.name }}-requests-{{ $slo.objective }}-latency"
    objective: {{ $slo.objective }}
    description: "Common SLO based on latency for HTTP request responses"
    sli:
      events:
        errorQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" $ | quote }}}[5m])))[{{.window}}:5m]) - sum_over_time((sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name={{ include "fullname" . | quote }},le="{{ $slo.target }}"}[5m])))[{{.window}}:5m])
        totalQuery: sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name={{ include "fullname" $ | quote }}}[5m])))[{{.window}}:5m]) > 0
    alerting:
      name: {{ $slo.name }}
      labels:
        category: "latency"
      annotations:
        summary: "High latency on requests responses"
      pageAlert:
        disable: true
      ticketAlert:
        disable: true
{{- end }}
---
{{- end }}
{{- end }}
