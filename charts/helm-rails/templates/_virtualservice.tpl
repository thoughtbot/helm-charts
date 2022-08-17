{{- define "virtualservice" -}}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ .namespace.name }}-{{ .Release.Name }}-virtualservice
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
{{- with .virtualservice.gateways }}
  gateways:
{{- . | toYaml | nindent 2 }}
{{- end -}}
{{ with .namespace.hosts }}
  hosts:
{{- . | toYaml | nindent 2 }}
{{- end }}
  http:
{{- range $key, $service := .Values.services }}
{{- $_ := merge $service (deepCopy $.Values.defaults) -}}
{{- if $service.virtualservice.matchprefix }}
  - match:
    - uri:
        prefix: {{ $service.virtualservice.matchprefix }}
    retries:
      attempts: {{ .virtualservice.retries.attempts }}
    route:
    - destination:
{{- $values := dict "Values" $.Values "Release" $.Release -}}
{{- $_ := set $values "component" (default $key $service.name) }}
        host: {{ include "fullname" $values }}
        port:
          number: {{ $.Values.defaults.service.http.port }}
{{- if $service.virtualservice.headers }}
    headers:
      request:
        set:
          x-request-start: {{ index .virtualservice.requestheaders "x-request-start" }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
