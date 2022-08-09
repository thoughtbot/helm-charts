{{- define "secretproviderclass" }}
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: {{ .secretName }}
  namespace: {{ .namespace.name }}
  labels:
    {{- include "labels" . | nindent 4 }}
spec:
  parameters:
      objects: |
      {{- range $key, $secretkeys := .secretproviderclass }}
        - objectName: {{ $key }}
          objectType: secretsmanager
          jmesPath:
          {{- range $secretkeys.secretkeys }}
          - path: {{ . }}
            objectAlias: {{ . }}
          {{- end }}
      {{- end }}
  provider: aws
  secretObjects:
  - secretName: {{ .secretName }}
    type: Opaque
    data:
    {{- range $secretkeys := .secretproviderclass }}
    {{- range $secretkeys.secretkeys }}
    - key: {{ . }}
      objectName: {{ . }}
    {{- end }}
    {{- end }}
{{- end }}
