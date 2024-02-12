#!/usr/bin/env bash

download_remote_schema() {
  # See: https://github.com/instrumenta/openapi2jsonschema/issues/49
  mkdir -p ${1}/schemas
  curl -kL -H "Authorization: Bearer $(oc whoami -t)" $(oc whoami --show-server)/openapi/v2 | jq '.definitions[] |= if .["x-kubernetes-group-version-kind"] then . + {properties: (.properties // {})} else . end' > ${1}/openshift-openapi-spec.json
}

generate_all_schemas() {
  podman run -i -v ${PWD}:${PWD} -v "${PWD}/${1}:/out" ghcr.io/yannh/openapi2jsonschema:latest --expanded --kubernetes --stand-alone --strict "${PWD}/${1}/openshift-openapi-spec.json"
}

full_ocp_version=$(oc version -o json | jq -r '.openshiftVersion')
ocp_version="${full_ocp_version::-3}"

echo "oc version returned '${full_ocp_version}', using '${ocp_version}'"

download_remote_schema ${ocp_version}
generate_all_schemas ${ocp_version}