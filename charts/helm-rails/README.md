# Helm Chart for Rails Applications

This [Helm] chart can be used to quickly generate [Kubernetes manifests] to
deploy a Rails application to a Kubernetes cluster. It's intended to be used as
part of a CI/CD pipeline.

[Helm]: https://helm.sh/
[Kubernetes manifests]: https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/

Look in [template-test](./template-test/README.md) for an example configuration.

## Prerequisites

- Helm 3+

## Get Repo Info

```console
helm repo add thoughtbot-charts https://thoughtbot.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] thoughtbot-charts/helm-rails
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

There are no dependencies to use this chart

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._


## Configuration

To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values thoughtbot-charts/helm-rails
```
