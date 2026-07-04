.DEFAULT_GOAL := help

KUBECONFORM_IMAGE ?= ghcr.io/yannh/kubeconform:v0.7.0@sha256:85dbef6b4b312b99133decc9c6fc9495e9fc5f92293d4ff3b7e1b30f5611823c
OCP_SCHEMA_VERSION ?= 4.19.0

.PHONY: help generate test

help:
	@echo "Available targets:"
	@echo "  generate  Generate schemas from the logged-in OpenShift cluster"
	@echo "  test      Run kubeconform smoke tests against sample fixtures"

generate:
	@bash ./generate.sh

test:
	podman run --rm \
		-v "$(CURDIR):$(CURDIR)" \
		-w "$(CURDIR)" \
		$(KUBECONFORM_IMAGE) \
		-summary \
		-kubernetes-version $(OCP_SCHEMA_VERSION) \
		-schema-location "$(CURDIR)/{{ .NormalizedKubernetesVersion }}/schemas/{{ .ResourceKind }}{{ .KindSuffix }}.json" \
		test/fixtures/route.yaml \
		test/fixtures/securitycontextconstraints.yaml \
		test/fixtures/deployment.yaml \
		test/fixtures/bad-deployment.yaml
