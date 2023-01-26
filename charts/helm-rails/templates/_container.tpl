{{- define "container" -}}
{{- with .args -}}
args:
{{ . | toYaml }}
{{ end -}}
{{- with .command -}}
command:
{{ . | toYaml }}
{{ end -}}
{{ with .env -}}
env:
{{- . | toYaml | nindent 0 }}
{{ end -}}
{{- if or .secretproviderclasses .envFrom -}}
envFrom:
{{ with .envFrom -}}
{{ range . -}}
{{- with .configMapRef -}}
{{- if hasKey $.Values.config .name -}}
{{- $namedRef := deepCopy . -}}
{{- $_ := set $namedRef "Release" $.Release -}}
{{- $_ := set $namedRef "Values" (deepCopy $.Values) -}}
{{- $_ := set $namedRef "component" .name -}}
{{- $_ := set . "name" (include "fullname" $namedRef) -}}
{{- end -}}
{{- end -}}
- {{ . | toYaml | nindent 2 | trim }}
{{ end -}}
{{ end -}}
{{- range $key, $secretproviderclass := .secretproviderclasses -}}
- secretRef:
    name: {{ $key | trim }}
{{ end -}}
{{- end -}}
image: {{ default .appImage .image }}:{{ default .appVersion .version }}
imagePullPolicy: {{ default "IfNotPresent" .imagePullPolicy }}
name: {{ .name }}
{{ with .ports -}}
ports:
{{ . | toYaml }}
{{ end -}}
{{ with .livenessProbe -}}
livenessProbe:
{{- . | toYaml | nindent 2 }}
{{ end -}}
{{ with .readinessProbe -}}
readinessProbe:
{{- . | toYaml | nindent 2 }}
{{ end -}}
{{ with .resources -}}
resources:
{{- . | toYaml | nindent 2 }}
{{ end -}}
{{- if or .secretproviderclasses .csiSecrets -}}
volumeMounts:
{{- range .csiSecrets }}
- name: {{ . }}
  mountPath: {{ printf "/csiSecrets/%s" . }}
  readOnly: true
{{- end -}}
{{- range $key, $secretproviderclass := .secretproviderclasses }}
- name: {{ $key }}
  mountPath: {{ printf "/%s" $key }}
  readOnly: true
{{- end -}}
{{- end -}}
{{- end -}}
---
