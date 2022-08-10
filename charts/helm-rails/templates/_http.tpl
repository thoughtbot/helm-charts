{{- define "http" -}}
{{- $port := default .Values.defaults.service.http.port .container.http.port -}}
{{- $portName := default "http" .container.http.portName -}}
{{- $_ := set .container "args" (default (list "rails" "server") .container.args) -}}
{{- $_ := set .container "env" (append (default list .container.env) (dict "name" "PORT" "value" ($port | toString))) -}}
{{- $_ := set .container "ports" (append (default list .container.ports) (dict "name" $portName "containerPort" $port "protocol" "TCP")) -}}
{{- $readinessProbe := merge (default dict .container.readinessProbe) (dict "initialDelaySeconds" 10 "periodSeconds" 10 "timeoutSeconds" 2) -}}
{{- $_ := set .container "readinessProbe" $readinessProbe -}}
{{- $httpGet := merge (default dict .container.readinessProbe.httpGet) (dict "path" "/robots.txt" "port" 3000 "httpHeaders" (list (dict "name" "Host" "value" (default "example.com" .container.readinessprobehost)))) -}}
{{- $_ := set .container.readinessProbe "httpGet" $httpGet -}}
{{- $ports := concat (list (dict "name" $portName "port" $port "protocol" "TCP" "targetPort" $portName)) (default list .service.ports) -}}
{{- $_ := set .service "ports" $ports -}}
{{- $_ := set .service "type" (default "ClusterIP" .service.type) -}}
{{- end -}}
