# cerebral-docs

[cerebral-docs](https://github.com/Workiva/slate)


## Configuration

Parameter | Description | Default
--- | --- | ---
image.registry | Docker registry to pull image from | `drydock.workiva.org`
image.repo | Docker image repo | `workiva/slate`
image.tag | Docker image tag | `1467762`
replicas | The number of pod replicas to run | `0`
iamRole | IAM Role to attach to the pod | `nil`
minAvailable | The minimum number of available pods during updates | `75%`
autoscaling.minReplicas | The minimum number of replicas when autoscaling | `3`
autoscaling.maxReplicas | The maximum number of replicas when autoscaling | `10`
autoscaling.metrics | List of metrics to scale on | `[]`
ingress.clusterDomain | The base domain of the cluster the chart is being deployed to | Value should be supplied at runtime. Ex: `wk-dev.wdesk.org`
secrets.TRACE_SAMPLING | TODO | Value should be supplied at runtime
resources.limits.cpu | CPU limit for pod | `0.25`
resources.limits.memory | Memory limit for pod | `512Mi`
resources.requests.cpu | Requested CPU for pod | `0.25`
resources.requests.memory | Requested Memory for pod | `512Mi`
readinessProbe.httpGet.path | Path to request for readiness probe | `/s/cerebral-docs/`
readinessProbe.httpGet.port | Port to request for readiness probe | `8000`
readinessProbe.initialDelaySeconds | Time to wait before performing readiness probe | `10`
readinessProbe.periodSeconds | Time between readiness probes | `10`
readinessProbe.timeoutSeconds | Timeout for individual readiness probe | `10`
livenessProbe.exec.command | Command to execute for liveness probe | `nil`
livenessProbe.httpGet.path | Path to request for liveness probe | `nil`
livenessProbe.httpGet.port | Port to request for liveness probe | `nil`
livenessProbe.initialDelaySeconds | Time to wait before performing liveness probe | `5`
livenessProbe.periodSeconds | Time between liveness probes | `10`
livenessProbe.timeoutSeconds | Timeout for individual liveness probe | `10`

## Environment Variables

Environment variables for the application container can be configured via the
`environment` section of the `values.yaml` file:

```yaml
environment:
  MY_ENV_VAR: my_value
```

Or via the commandline:

```console
$ helm install --name cerebral-docs --set environment.MY_ENV_VAR=value .
```

## Secrets

Sensitive values which need to be supplied to the application container should
be configured via the `secrets` section of the `values.yaml` file:

```yaml
secrets:
  MY_SECRET: ''
```

**Caution:** The values of secrets should not be committed unless they are only
used for local development.

Secrets should be passed in at runtime via the commandline:

```console
$ helm install --name cerebral-docs --set secrets.MY_SECRET=secret_value .
```

Values provided as secrets will uploaded as Kubernetes Secrets and mounted into containers as environment variables with the provided name.

## Mounted Files

Arbitrary files can be mounted into containers. This is done by mounting a Kubernetes Secrets as a volume in the container.
Any files being mounted will need to exist within the `files/` before installing the chart.

**Notes:**
- Only one secret can be mounted to a single directory.
- Multiple files can be included in a single secret.
- An individual secret is limited to 1MB in size.
- Any files that existed within the directory the volume is mounted to will be wiped.

More info: https://kubernetes.io/docs/concepts/configuration/secret/

## Health Checks

Health checks for pods are broken into two parts, a readiness probe and a liveness probe. The readiness probe dictates whether the container should receive http traffic and the liveness probe indicates the container should be restarted.

More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/

## Ingress

Ingress defines how a service can be externally reached. These are similar to the Harbour routing rules. Your initial configuration should match your configuration in production harbours.

**Warning**: Take care when editing ingress, the rules apply globably. You can break things for yourself and others.

We use the kubernetes/ingress-nginx controller to handle our ingress.

More info: https://kubernetes.io/docs/concepts/services-networking/ingress/

The chart value `clusterDomain` defines the hostname of the cluster your service is running in.

Example:
```
clusterDomain: wk-dev.wdesk.com
```

## Autoscaling

Kubernetes uses a resource called `HorizontalPodAutoscaler` to control scaling your service. You can scale based on CPU, Memory, and Custom metrics.

More info: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

In addition to the `HorizontalPodAutoscaler`, setting a `PodDisruptionBudget` helps ensure that your service will always be highly available.

More info: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

## TODO's

- [ ] Verify that there aren't any sensitive values in environment section. Clean up unused secrets and environment vars `values.yaml`
- [ ] Configure Liveness probe. See `values.yaml`
- [ ] Enable CPU or memory based autoscaling for your application if possible. See `values.yaml`
- [ ] If possible, raise your `minAvailable` and `autoscaling.minReplicas` to at least three for your application.
  This is a best practice which helps to ensure a highly available application.
- [ ] Check if your container can run run as non-root user and update values.yaml accordingly
- [ ] Upgrade to latest app-intelligence/messaging-sdk libraries.
- [ ] Update your team name in the charts.yaml.
- [ ] Select a serviceAvailabilityType in the charts.yaml.

## Local Development

Setup a local Kubernetes cluster using either [minikube](https://kubernetes.io/docs/setup/minikube/) or [Docker for Mac](https://docs.docker.com/docker-for-mac/kubernetes/)

### Installing / Upgrading the Chart

Initialize helm in your cluster if you have not already done so. https://docs.helm.sh/helm/#helm-init

```console
$ helm init
```

https://docs.helm.sh/helm/#helm-upgrade

_Note_ : If you want to set a value like `12345`, such as setting an image id, you will want to use `--set-string` to
avoid helm converting your number to a float. [Customizing Charts](https://docs.helm.sh/using_helm/#customizing-the-chart-before-installing)

```console
$ helm upgrade --install \
       --set ingress.clusterDomain="CLUSTER_DOMAIN_PLACEHOLDER" \
       --set secrets.TRACE_SAMPLING="TRACE_SAMPLING_PLACEHOLDER" \
       cerebral-docs .
```

If you want to reuse values when doing an upgrade, you can use the
`--reuse-values` flag. This will reuse values from the previous release
of the chart and merge in any values passed in.

```console
$ helm upgrade --reuse-values cerebral-docs .
```

### Deleting the Chart

https://docs.helm.sh/helm/#helm-delete

```console
$ helm delete --purge cerebral-docs
```

### Testing Changes to Chart

#### Linting

https://docs.helm.sh/helm/#helm-lint

```console
$ helm lint .
```

#### Dry Run

```console
$ helm install --dry-run --debug --name cerebral-docs .
```
