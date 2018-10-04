# Use Knative Build with IBM Cloud Container Registry

* Based on [Orchestrating a source-to-URL deployment on Kubernetes
](https://github.com/knative/docs/tree/master/serving/samples/source-to-url-go)
* Adapted for IBM Cloud Container Registry.

## Prerequisites

You need:
* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md) if you need to create one.
* [ibmcloud CLI](https://console.bluemix.net/docs/cli/index.html#overview)
* kubectl
* envsubst
  * on macOS, get it with `brew install gettext`

## Configuring Knative

To use this sample, you need to install a build template and register a secret for IBM Cloud Container Registry.

### Install the kaniko build template

This sample leverages the [kaniko build template](https://github.com/knative/build-templates/tree/master/kaniko)
to perform a source-to-container build on your Kubernetes cluster.

Use kubectl to install the kaniko manifest:

```shell
kubectl apply --filename https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
```

## Register secrets for IBM Cloud Container Registry

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

1. Copy the template file:

   ```sh
   cp local.template.env local.env
   ```

1. Edit `local.env` and adjust the values to match your environment.

1. Load the environment variables:

   ```sh
   source local.env
   ```

1. Create a `Secret` to store the credentials for the registry, and a `ServiceAccount` to run the build:

   ```
   cat docker-secret.yaml | envsubst | kubectl apply -f -
   ```

## Deploy the sample

Now that the secret and service account have been created, you can deploy the service. The sample uses a very [simple app](https://github.com/mchmarny/simple-app.git). knative will build the app from its source, then push the image to the IBM Cloud Container Registry.

1. Create a knative `Service`:

   ```
   cat service.yaml | envsubst | kubectl apply -f -
   ```

1. Watch the pods for build and serving

   ```
   kubectl get pods --watch
   ```

1. Once the deployment pod is running, you can escape the watch and access the running application. Just follow [the steps from the original tutorial](https://github.com/knative/docs/tree/master/serving/samples/source-to-url-go#deploying-the-sample) starting at step 3.

1. Look for a new image named `cr-app-from-source` under your namespace in IBM Cloud Container Registry:

   ```sh
   ibmcloud cr images --restrict $NAMESPACE
   ```

## To clean up

```
kubectl delete -f service.yaml
kubectl delete -f docker-secret.yaml
ibmcloud cr image-rm $REGISTRY/$NAMESPACE/cr-app-from-source:latest
```

