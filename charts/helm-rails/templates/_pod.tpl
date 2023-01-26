{{- define "pod" -}}
metadata:
  labels:
    {{- include "selectorLabels" . | nindent 4 }}
  {{- with .podannotations }}
  annotations:
    {{- . | toYaml | nindent 4 }}
  {{- end }}
spec:
  containers:
{{- $containerDefaults := deepCopy .container -}}
{{- $_ := set $containerDefaults "appImage" .Values.app.image }}
{{- $_ := set $containerDefaults "appVersion" .Values.app.version }}
{{- $_ := set $containerDefaults "csiSecrets" .csiSecrets }}
{{- if .secretproviderclasses }}
{{- $_ := set $containerDefaults "secretproviderclasses" .secretproviderclasses  }}
{{- end }}
{{- range $key, $container := .containers }}
{{- $_ := merge $container $containerDefaults }}
{{- $_ := set $container "name" (default $key $container.name) }}
{{- $_ := set $container "Release" $.Release }}
{{- $_ := set $container "Values" (deepCopy $.Values) }}
  - {{ include "container" $container | nindent 4 | trim }}
{{- end }}
{{- if .initContainers }}
  initContainers:
{{- range $key, $container := .initContainers -}}
{{- $_ := merge $container $containerDefaults }}
{{- $_ := set $container "name" (default $key $container.name) }}
{{- $_ := set $container "Release" $.Release }}
{{- $_ := set $container "Values" (deepCopy $.Values) }}
  - {{ include "container" $container | nindent 4 | trim }}
{{- end }}
{{- end }}
{{- with .securityContext }}
  securityContext:
    {{ . | toYaml | nindent 4 | trim }}
{{- end }}
{{- with .restartPolicy }}
  restartPolicy: {{ . }}
{{- end }}
{{- range $key, $podserviceaccount := .podserviceaccounts }}
  serviceAccountName: {{ quote $key }}
{{- end }}
{{- with .topologySpreadConstraints }}
  topologySpreadConstraints:
{{- range . }}
  - {{ . | toYaml | nindent 4 | trim }}
{{- if not .labelSelector }}
    labelSelector:
      matchLabels:
{{- include "selectorLabels" $ | nindent 8 }}
{{- end }}
{{- end }}
{{- end }}
{{- if or .volumes .csiSecrets .secretproviderclasses }}
  volumes:
{{- range .volumes }}
{{ with .configMap }}
{{- if hasKey $.Values.config .name -}}
{{- $namedRef := deepCopy . -}}
{{- $_ := set $namedRef "Release" $.Release -}}
{{- $_ := set $namedRef "Values" (deepCopy $.Values) -}}
{{- $_ := set . "name" (include "fullname" $namedRef) -}}
{{ end }}
{{ end }}
  - {{ . | toYaml | nindent 4 | trim }}
{{- end }}
{{- range .csiSecrets }}
  - name: {{ . }}
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: {{ . }}
{{- end -}}
{{- range $key, $secretproviderclass := .secretproviderclasses }}
  - name: {{ $key }}
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: {{ $key }}
{{- end }}
{{- end }}
{{- end -}}
