# Summary

A quick Kong demo to demonstrate capabilities of the AI gateway.


## Getting Started

1. Ensure you set environment variables needed for the demo.  We store these in
the environment so we do not accidentally expose these secrets:

```bash
export TF_VAR_kong_access_token=...   # your kong api access token. used for api calls to kong konnect.
export TF_VAR_openai_access_token=... # your openai api access token.  used for api calls to openai.

# also set the environment variable if using the demo script instead of the UI
export OPENAI_API_KEY=$TF_VAR_openai_access_token
```

2. Ensure you have a Kubernetes cluster running.  The following command uses KIND:

```bash
make cluster
```

1. Install the prereq manifests needed for the gateway:

```bash
make cluster-config
```

1. Configure Kong and the Demo App:

```bash
make kong
```
