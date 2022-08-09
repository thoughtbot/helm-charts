CHART_DIR="$PWD"

setup() {
  mkdir -p "$TEST_TMPDIR"
  cd "$TEST_TMPDIR"
  mkdir -p "working"
  cd "working"
}

teardown() {
  cd "$TEST_TMPDIR"
  rm -rf "working"
}

render() {
  if helm template "${APP_NAME:-example-app}" "$CHART_DIR" --values - > output.yaml; then
    if yamltojson < output.yaml > output.json; then
      cp output.json selected.json
    else
      echo "Failed to parse output" >&2
      false
    fi
  else
    echo "Failed to render template" >&2
    false
  fi

  SELECTOR="cat output.json"
}

select_json() {
  if jq "$@" < selected.json > reselect.json \
    && [ "$(cat reselect.json)" != "null" ]; then
    mv reselect.json selected.json
    SELECTOR="$SELECTOR | jq $@"
  else
    echo "In YAML:" >&2
    cat output.yaml >&2
    echo >&2
    echo "Unable to find element matching selector:" >&2
    echo "$*"
    false
  fi
}

select_object() {
  reset_selection
  if ! select_json \
    --arg kind "$1" \
    --arg name "$2" \
    --slurp \
    'map(select(.kind == $kind and .metadata.name == $name)) | .[0]'; then
    echo "Unable to find object of kind $1 with name $2" >&2
    false
  fi
}

assert_no_object() {
  if select_object "$1" "$2" 2>/dev/null; then
    echo "Found unexpected object of kind $1 with name $2" >&2
    false
  fi
}

reset_selection() {
  cp output.json selected.json
}

assert_label() {
  assert_json ".metadata.labels[\"$1\"]" "$2"
}

assert_json() {
  if result=$(jq -r "$1" < selected.json); then
    if [ "$2" != "$result" ]; then
      echo "From YAML:"
      cat output.yaml
      echo
      echo "In JSON selected from $SELECTOR:"
      cat selected.json
      echo
      echo "Query:    $1"
      echo "Expected: $2"
      echo "Actual:   $result"
      false
    fi
  else
    echo "Failed to run jq" >&2
    false
  fi
}

assert_nested_json() {
  if result=$(jq -r "$1" < selected.json | foreignyamltojson | jq -c .); then
    expected=$(echo "$2" | jq -c .)
    if [ "$expected" != "$result" ]; then
      echo "From YAML:"
      cat output.yaml
      echo
      echo "In JSON selected from $SELECTOR:"
      cat selected.json
      echo
      echo "Query:    $1"
      echo "Expected: $2"
      echo "Actual:   $result"
      false
    fi
  else
    echo "Failed to run jq" >&2
    false
  fi
}

foreignyamltojson() {
  (
    echo "kind: Object"
    cat
  ) | yamltojson | jq 'del(.kind)'
}

yamltojson() {
  kubectl patch \
    --type json \
    --local \
    --output json \
    --filename - \
    --patch "[]"
}
