{{- define "service" -}}
{{- if .service.ports }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "fullname" . }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
{{- with .service.ports }}
  ports:
{{- range . }}
  - name: {{ .name }}
    port: {{ .port }}
    protocol: {{ default "TCP" .protocol }}
    targetPort: {{ default .port .targetPort }}
{{- end -}}
{{ end }}
  selector:
    {{- include "selectorLabels" . | nindent 4 }}
  type: {{ default "None" .service.type }}
{{- end -}}
{{- end -}}