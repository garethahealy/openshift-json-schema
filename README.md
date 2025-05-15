# openshift-json-schema

[kubernetes-json-schema](https://github.com/yannh/kubernetes-json-schema) but for OpenShift. Consumed by [redhat-cop/rego-policies](https://github.com/redhat-cop/rego-policies/blob/main/.github/workflows/gatekeeper-k8s-integrationtests.yaml#L59-L65)

## usage

```bash
oc login --token=replaceme --server=https://api.ocp-cluster.com:6443

./generate.sh
```
