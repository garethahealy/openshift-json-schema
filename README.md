# openshift-json-schema

[kubernetes-json-schema](https://github.com/yannh/kubernetes-json-schema) but for OpenShift.
Consumed by [redhat-cop/rego-policies](https://github.com/redhat-cop/rego-policies/blob/main/.github/workflows/gatekeeper-k8s-integrationtests.yaml#L59-L65).

This repository stores versioned, standalone JSON Schema files for OpenShift and Kubernetes API resources.
Schemas are generated from a live cluster's OpenAPI v2 spec and used to validate manifests offline with tools such as [kubeconform](https://github.com/yannh/kubeconform).

## Versions

Each version directory contains:

```
v4.19.0/
├── openshift-openapi-spec.json   # Raw OpenAPI v2 from the generating cluster
└── schemas/
    ├── _definitions.json         # Full merged definition graph
    ├── route-route-v1.json       # Standalone per-resource schemas
    └── ...
```

## Validating manifests

### kubeconform

Validate manifests against a specific OpenShift version using in-repo schemas:

```bash
kubeconform -summary \
  -kubernetes-version 4.19.0 \
  -schema-location 'https://raw.githubusercontent.com/garethahealy/openshift-json-schema/main/{{ .NormalizedKubernetesVersion }}/schemas/{{ .ResourceKind }}{{ .KindSuffix }}.json' \
  manifests/
```

Validate against a local checkout:

```bash
kubeconform -summary \
  -kubernetes-version 4.19.0 \
  -schema-location "${PWD}/{{ .NormalizedKubernetesVersion }}/schemas/{{ .ResourceKind }}{{ .KindSuffix }}.json" \
  manifests/
```

## Generating schemas

Prerequisites: `oc`, `jq`, and `podman`.

```bash
oc login https://api.ocp-cluster.com:6443 --web

make generate
```

## Makefile targets

```bash
make help       # list available targets
make generate   # generate schemas from the logged-in cluster
make test       # run kubeconform smoke tests against test/fixtures/
```
