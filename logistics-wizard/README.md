# Moving a Cloud Foundry app to Knative on IBM Cloud

A companion project to [this Medium post](https://medium.com/@frederic.lavigne/moving-a-cloud-foundry-app-to-knative-on-ibm-cloud-c0787e3611f1).

## Prerequisites

You need:
* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md) if you need to create one.
* [ibmcloud CLI](https://console.bluemix.net/docs/cli/index.html#overview)
* kubectl
* envsubst
  * on macOS, get it with `brew install gettext`
  * on Ubuntu, `apt-get install gettext`

## Configuring Knative

To use this sample, you need to install a build template and register a secret for IBM Cloud Container Registry.

### Install the kaniko build template

This sample leverages the [kaniko build template](https://github.com/knative/build-templates/tree/master/kaniko)
to perform a source-to-container build on your Kubernetes cluster.

Use kubectl to install the kaniko manifest:

```shell
kubectl apply --filename https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
```

## Configure environment variables

1. Generate a registry token:

   ```sh
   ibmcloud cr token-add --non-expiring --readwrite --description "used by knative build"
   ```

   It outputs:
   ```
   Requesting a registry token...

   Token identifier   123-456
   Token              eyBlahBlahBlah.moreBlahBlahBlahNTAzNmMim5ldCJ9.dkdjeidndkdkeo300NWQ

   OK
   ```

   This token can be used to authenticate with the IBM Cloud Container registry. The username to use will be `token` and the password the value of the generated token, `eyBlahBlahBlah.moreBlahBlahBlahNTAzNmMim5ldCJ9.dkdjeidndkdkeo300NWQ` in the example above.

1. Obtain your cluster ingress domain:

   ```sh
   ibmcloud ks cluster-get <cluster_name>
   ```

1. Copy the template file:

   ```sh
   cp local.template.env local.env
   ```

1. Edit `local.env` and adjust the values to match your environment.

## Deploy the services

1. Run the deployment script:

   ```sh
   ./do.sh --install
   ```

   The script will:
   * configure the Knative domain to point to your cluster ingress;
   * create a secret and a service account to build the Docker images used by the Logistics Wizard services;
   * build and deploy ERP, Controller and Web UI
   * create an ingress for all services
   * watch all pods

1. Access the app at http://lw-webui.default.$INGRESS_DOMAIN

## To clean up

```
./do.sh --uninstall
ibmcloud cr image-rm $REGISTRY/$NAMESPACE/lw-webui:latest
ibmcloud cr image-rm $REGISTRY/$NAMESPACE/lw-controller:latest
ibmcloud cr image-rm $REGISTRY/$NAMESPACE/lw-erp:latest
```

