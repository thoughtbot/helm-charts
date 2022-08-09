# Example

Running the following command:

    helm template example-app thoughtbot/helm-rails \
      --values values.yaml \
      --output-dir .

Will take the [example values] and generate the [example manifests].

[example values]: ./values.yaml
[example manifests]: ./helm-rails/templates
