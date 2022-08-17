#!/usr/bin/env bats

load helpers

@test "adds pod properties" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        rails:
          http: {}
    defaults:
      containers:
        main:
          livenessProbe:
            failureThreshold: 3
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 2
            httpGet:
              path: /robots.txt
              port: 3000
          resources:
            requests:
              cpu: "128m"
              memory: "512Mi"
            limits:
              memory: "1024Mi"
      pod:
        securityContext:
          fsGroup: 1234
        serviceAccountName: example-app
        topologySpreadConstraints:
        - maxSkew: 3
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
YAML

  select_object 'Deployment' 'example-app-web'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].livenessProbe.failureThreshold' '3'
  assert_json '.containers[0].resources.requests.cpu' '128m'
  assert_json '.containers[0].resources.requests.memory' '512Mi'
  assert_json '.containers[0].resources.limits.memory' '1024Mi'
  assert_json '.securityContext.fsGroup' '1234'
  assert_json '.topologySpreadConstraints[0].maxSkew' '3'
  assert_json '.topologySpreadConstraints[0].topologyKey' \
    'topology.kubernetes.io/zone'
  assert_json '.topologySpreadConstraints[0].whenUnsatisfiable' 'DoNotSchedule'
  assert_json \
    '.topologySpreadConstraints[0].labelSelector.matchLabels["app.kubernetes.io/name"]' \
      'example-app'
}
