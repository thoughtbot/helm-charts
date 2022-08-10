{{- define "sidekiq" -}}
{{- $args := dict "v" (default (list "sidekiq") .container.args) -}}
{{- with .container.sidekiq.queues -}}
{{- range . -}}
{{- $_ := set $args "v" (concat $args.v (list "-q" .)) -}}
{{- end -}}
{{- end -}}
{{- with .container.sidekiq.concurrency -}}
{{- $_ := set $args "v" (concat $args.v (list "-c" (toString .))) -}}
{{- end -}}
{{- $_ := set .container "args" $args.v -}}
{{- end -}}
