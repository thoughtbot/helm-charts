{{- define "serviceaccount" }} 
{{- if .serviceaccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .serviceaccountname }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
  annotations: 
    eks.amazonaws.com/role-arn: {{ required (printf ".serviceaccount.%s.iamrolearn role is required if .serviceaccount.%s.create is true" .serviceaccountname .serviceaccountname ) .serviceaccount.iamrolearn }}
{{- end }}
{{- end }}
