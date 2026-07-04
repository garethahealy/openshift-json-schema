#!/usr/bin/env bash
set -euo pipefail

normalize_ocp_version() {
  local full_version="${1}"
  local major_minor

  major_minor="$(echo "${full_version}" | sed -nE 's/^([0-9]+\.[0-9]+).*/\1/p')"
  if [[ -z "${major_minor}" ]]; then
    echo "error: unable to parse OpenShift version from '${full_version}'" >&2
    exit 1
  fi

  echo "v${major_minor}.0"
}

download_remote_schema() {
  local version_dir="${1}"

  # See: https://github.com/instrumenta/openapi2jsonschema/issues/49
  mkdir -p "${version_dir}/schemas"
  oc get --raw /openapi/v2 \
    | jq '.definitions[] |= if .["x-kubernetes-group-version-kind"] then . + {properties: (.properties // {})} else . end' \
    > "${version_dir}/openshift-openapi-spec.json"
}

generate_all_schemas() {
  local version_dir="${1}"

  podman run --rm -i \
    -v "${PWD}:${PWD}" \
    -v "${PWD}/${version_dir}:/out" \
    ghcr.io/garethahealy/openapi2jsonschema:latest \
    --expanded --kubernetes --stand-alone --strict \
    "${PWD}/${version_dir}/openshift-openapi-spec.json"
}

if ! oc whoami >/dev/null 2>&1; then
  echo "error: not logged in to an OpenShift cluster; run 'oc login' first" >&2
  exit 1
fi

if ! oc_version_json="$(oc version -o json 2>&1)"; then
  echo "error: 'oc version -o json' failed:" >&2
  echo "${oc_version_json}" >&2
  exit 1
fi

full_ocp_version="$(echo "${oc_version_json}" | jq -er '.openshiftVersion // empty')"
if [[ -z "${full_ocp_version}" || "${full_ocp_version}" == "null" ]]; then
  echo "error: could not read OpenShift version from cluster" >&2
  echo "hint: ensure you are logged in to an OpenShift cluster, not plain Kubernetes" >&2
  echo "oc version output:" >&2
  echo "${oc_version_json}" | jq . >&2 || echo "${oc_version_json}" >&2
  exit 1
fi

normalized_ocp_version="$(normalize_ocp_version "${full_ocp_version}")"
echo "oc version returned '${full_ocp_version}', using '${normalized_ocp_version}'"

download_remote_schema "${normalized_ocp_version}"
generate_all_schemas "${normalized_ocp_version}"
