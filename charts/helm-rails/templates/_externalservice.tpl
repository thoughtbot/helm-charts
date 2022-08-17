{{- define "externalservice" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
{{- with .ports }}
  ports:
{{- range . }}
  - name: {{ .name }}
    port: {{ .port }}
    protocol: {{ default "TCP" .protocol }}
    targetPort: {{ default .port .targetPort }}
{{- end -}}
{{ end }}
  type: ExternalName
  {{- if eq .type "local" }}
  externalName: {{ required (printf "'name' value is mandatory for external service type of 'local'.") .name }}.{{ required (printf "'externalnamespace' value is mandatory for external service type of 'local'.") .externalnamespace }}.svc.cluster.local
  {{- else if eq .type "external" }}
  externalName: {{ required (printf "'url' value is mandatory for external service type of 'external'.") .url }}
  {{- else }}
  {{ fail (printf "External service type can either be external or local. Wrong value of entered - %s." .type) }}
  {{- end }}
{{- end -}}