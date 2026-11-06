# JSReport Helm Chart

A Helm chart for deploying [JSReport](https://jsreport.net/) on Kubernetes. JSReport is a powerful reporting platform for generating reports from JavaScript templates.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [Configuration](#configuration)
- [Values](#values)
- [Examples](#examples)
- [Upgrading](#upgrading)
- [Contributing](#contributing)

## Prerequisites

- Kubernetes 1.18+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is required)

## Installation

### Add Helm Repository

```bash
# Add the JSReport Helm repository
helm repo add jsreport-helm https://ankosoftware.github.io/jsreport-helm/
helm repo update
```

### Install the Chart

The chart has no default admin password. Provide credentials inline or through an existing Secret, otherwise installation fails.

```bash
# Install with generated credentials
helm install my-jsreport jsreport-helm/jsreport \
  --set auth.adminPassword="$(openssl rand -base64 24)" \
  --set auth.cookieSecret="$(openssl rand -base64 32)"

# Install using an existing Secret with keys "admin-password" and "cookie-secret"
kubectl create secret generic jsreport-auth \
  --from-literal=admin-password="$(openssl rand -base64 24)" \
  --from-literal=cookie-secret="$(openssl rand -base64 32)"
helm install my-jsreport jsreport-helm/jsreport --set auth.existingSecret=jsreport-auth

# Install with custom values
helm install my-jsreport jsreport-helm/jsreport -f my-values.yaml

# Install in a specific namespace
helm install my-jsreport jsreport-helm/jsreport --namespace jsreport --create-namespace -f my-values.yaml

# Install from local chart (for development)
helm install my-jsreport charts/jsreport -f my-values.yaml
```

### Verify Installation

```bash
kubectl get pods -l "app.kubernetes.io/name=jsreport"
```

## Uninstallation

```bash
helm uninstall my-jsreport
```

## Configuration

The following table lists the configurable parameters of the JSReport chart and their default values.

## Values

| Key                                          | Type   | Default                                                                                        | Description                                      |
| -------------------------------------------- | ------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `replicaCount`                               | int    | `1`                                                                                            | Number of JSReport replicas                      |
| `image.repository`                           | string | `"jsreport/jsreport"`                                                                          | JSReport image repository                        |
| `image.pullPolicy`                           | string | `"IfNotPresent"`                                                                               | Image pull policy                                |
| `image.tag`                                  | string | `"4.15.0-full"`                                                                                 | JSReport image tag                               |
| `auth.adminUsername`                         | string | `"admin"`                                                                                      | Admin username                                   |
| `auth.adminPassword`                         | string | `""`                                                                                           | Admin password (required unless `auth.existingSecret` is set) |
| `auth.cookieSecret`                          | string | `""`                                                                                           | Session cookie secret (required unless `auth.existingSecret` is set) |
| `auth.existingSecret`                        | string | `""`                                                                                           | Existing Secret with keys `admin-password` and `cookie-secret` |
| `trustUserCode`                              | bool   | `false`                                                                                        | Allow templates/scripts unrestricted module and local file access |
| `cors.enabled`                               | bool   | `false`                                                                                        | Allow cross-origin browser requests to the API   |
| `env`                                        | list   | See values.yaml                                                                                | Additional environment variables for JSReport configuration |
| `imagePullSecrets`                           | list   | `[]`                                                                                           | Image pull secrets                               |
| `nameOverride`                               | string | `""`                                                                                           | Override name of the chart                       |
| `fullnameOverride`                           | string | `""`                                                                                           | Override fullname of the chart                   |
| `serviceAccount.create`                      | bool   | `true`                                                                                         | Create service account                           |
| `serviceAccount.automount`                   | bool   | `false`                                                                                        | Automount service account token                  |
| `serviceAccount.annotations`                 | object | `{}`                                                                                           | Service account annotations                      |
| `serviceAccount.name`                        | string | `""`                                                                                           | Service account name                             |
| `podAnnotations`                             | object | `{}`                                                                                           | Pod annotations                                  |
| `podLabels`                                  | object | `{}`                                                                                           | Pod labels                                       |
| `podSecurityContext`                         | object | UID/GID/fsGroup `2500`, `runAsNonRoot`, `RuntimeDefault` seccomp                               | Pod security context                             |
| `securityContext`                            | object | Drop all capabilities, no privilege escalation                                                 | Container security context                       |
| `service.type`                               | string | `"ClusterIP"`                                                                                  | Service type                                     |
| `service.port`                               | int    | `5488`                                                                                         | Service port                                     |
| `ingress.enabled`                            | bool   | `false`                                                                                        | Enable ingress                                   |
| `ingress.className`                          | string | `""`                                                                                           | Ingress class name                               |
| `ingress.annotations`                        | object | `{}`                                                                                           | Ingress annotations                              |
| `ingress.hosts`                              | list   | `[{"host": "jsreport.local", "paths": [{"path": "/", "pathType": "ImplementationSpecific"}]}]` | Ingress hosts                                    |
| `ingress.tls`                                | list   | `[]`                                                                                           | Ingress TLS configuration                        |
| `resources`                                  | object | `{"limits": {"cpu": "1000m", "memory": "2Gi"}, "requests": {"cpu": "500m", "memory": "1Gi"}}`  | Resource limits and requests                     |
| `livenessProbe`                              | object | HTTP probe on port 5488                                                                        | Liveness probe configuration                     |
| `readinessProbe`                             | object | HTTP probe on port 5488                                                                        | Readiness probe configuration                    |
| `autoscaling.enabled`                        | bool   | `false`                                                                                        | Enable horizontal pod autoscaler                 |
| `autoscaling.minReplicas`                    | int    | `1`                                                                                            | Minimum number of replicas                       |
| `autoscaling.maxReplicas`                    | int    | `100`                                                                                          | Maximum number of replicas                       |
| `autoscaling.targetCPUUtilizationPercentage` | int    | `80`                                                                                           | Target CPU utilization percentage                |
| `volumes`                                    | list   | `/tmp`, Chrome cache and logs emptyDirs                                                        | Additional volumes                               |
| `volumeMounts`                               | list   | Mounts for the volumes above                                                                   | Additional volume mounts                         |
| `persistence.enabled`                        | bool   | `false`                                                                                        | Use a PersistentVolumeClaim for `/app/data` (emptyDir otherwise) |
| `persistence.existingClaim`                  | string | `""`                                                                                           | Use an existing claim instead of creating one    |
| `persistence.storageClass`                   | string | `""`                                                                                           | Storage class for the created claim              |
| `persistence.accessModes`                    | list   | `["ReadWriteOnce"]`                                                                            | Access modes for the created claim               |
| `persistence.size`                           | string | `"1Gi"`                                                                                        | Size of the created claim                        |
| `persistence.emptyDirSizeLimit`              | string | `"1Gi"`                                                                                        | Size limit of the emptyDir when persistence is disabled |
| `networkPolicy.enabled`                      | bool   | `true`                                                                                         | Create a NetworkPolicy for the jsreport pods     |
| `networkPolicy.ingress.from`                 | list   | `[]`                                                                                           | Sources allowed to reach the http port (empty allows all) |
| `networkPolicy.egress.blockedCidrs`          | list   | Metadata, link-local and private ranges                                                        | Ranges excluded from egress (IPv4 and IPv6)      |
| `networkPolicy.egress.extraEgress`           | list   | `[]`                                                                                           | Additional egress rules, e.g. for a database store |
| `nodeSelector`                               | object | `{}`                                                                                           | Node selector                                    |
| `tolerations`                                | list   | `[]`                                                                                           | Tolerations                                      |
| `affinity`                                   | object | `{}`                                                                                           | Affinity                                         |

### Environment Variables

The chart includes several important environment variables for JSReport configuration:

**Chrome/Puppeteer Configuration:**

- `chrome_launchOptions_args`: Chrome launch options optimized for Kubernetes
- Additional Chrome flags for stability and security

**Performance and Stability Settings:**

- `NODE_ENV`: Set to "production" for optimal performance
- `workers_numberOfWorkers`: Number of worker processes (default: 2)
- `NODE_OPTIONS`: Node.js memory management settings

Authentication, `trustUserCode` and CORS are configured through the `auth`, `trustUserCode` and `cors` values, not through `env`. Helm replaces lists instead of merging them, so keeping these settings out of `env` means overriding `env` cannot accidentally disable authentication.

## Examples

### Basic Installation

```bash
helm install jsreport jsreport-helm/jsreport --set auth.existingSecret=jsreport-auth
```

### Production Deployment with Custom Values

Create a `production-values.yaml` file:

```yaml
replicaCount: 3

auth:
  existingSecret: jsreport-auth

resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1Gi

networkPolicy:
  ingress:
    # Only the ingress controller and the API namespace may call jsreport
    from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ingress-nginx
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: my-api

ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: jsreport.yourdomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: jsreport-tls
      hosts:
        - jsreport.yourdomain.com

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

Deploy with:

```bash
helm install jsreport jsreport-helm/jsreport -f production-values.yaml
```

### Deployment with Persistent Storage

By default `/app/data` (templates and other entities saved by the file-system store) is an emptyDir and is lost when the pod restarts. Enable persistence to keep it:

```yaml
persistence:
  enabled: true
  size: 5Gi
  # storageClass: gp3
  # existingClaim: jsreport-data
```

A `ReadWriteOnce` claim can only be shared by replicas on the same node. For multiple replicas use a `ReadWriteMany` storage class or a database-backed jsreport store.

### Allowing Egress to Internal Services

The NetworkPolicy blocks egress to private networks. If jsreport needs an internal destination, such as a database store, allow it explicitly:

```yaml
networkPolicy:
  egress:
    extraEgress:
      - to:
          - podSelector:
              matchLabels:
                app.kubernetes.io/name: postgresql
        ports:
          - protocol: TCP
            port: 5432
```

### Accessing JSReport

After installation, get the application URL:

```bash
# For ClusterIP service (default)
export POD_NAME=$(kubectl get pods -l "app.kubernetes.io/name=jsreport" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:5488
echo "Visit http://127.0.0.1:8080 to use JSReport"

# For LoadBalancer service
kubectl get svc jsreport

# For Ingress
kubectl get ingress jsreport
```

## Upgrading

### Upgrading to 0.6.0

0.6.0 hardens the default configuration and contains breaking changes:

- **Credentials are required.** The `ChangeMe!` defaults were removed. Set `auth.adminPassword` and `auth.cookieSecret`, or `auth.existingSecret`. Remove any `extensions_authentication_*` entries from your `env` overrides.
- **The pod runs as UID/GID 2500**, the `jsreport` user of the image, instead of 1000. If you persisted `/app/data` with a custom volume, `fsGroup: 2500` makes it writable for the new user.
- **A NetworkPolicy is created** that blocks egress to cloud metadata endpoints, link-local and private networks. Add `networkPolicy.egress.extraEgress` rules for internal services jsreport must reach, or set `networkPolicy.enabled: false`.
- **The service account token is no longer mounted** (`serviceAccount.automount: false`).
- **CORS is disabled.** Set `cors.enabled: true` if browser pages on other origins call the API directly.
- **The data volume is managed by the chart.** Remove `data-volume` entries for `/app/data` from your `volumes`/`volumeMounts` overrides and use `persistence` instead.

### Upgrade the Chart

```bash
helm upgrade my-jsreport jsreport-helm/jsreport
```

### Upgrade with New Values

```bash
helm upgrade my-jsreport jsreport-helm/jsreport -f my-new-values.yaml
```

### Check Upgrade History

```bash
helm history my-jsreport
```

### Rollback

```bash
helm rollback my-jsreport 1
```

## JSReport-Specific Considerations

### Resource Requirements

JSReport requires significant resources due to Chrome/Puppeteer for PDF generation:

- **Minimum Memory**: 1Gi (recommended: 2Gi)
- **Minimum CPU**: 500m (recommended: 1000m)
- **Temporary Storage**: Required for Chrome cache and temp files

### Chrome/Puppeteer Configuration

The chart includes optimized Chrome launch options for Kubernetes:

- `--no-sandbox`: Required for running Chrome in containers
- `--disable-dev-shm-usage`: Prevents /dev/shm size issues
- `--disable-gpu`: Disables GPU acceleration (not needed for headless)
- Additional flags for stability and security

### Worker Configuration

JSReport supports multiple worker processes for better performance:

- Default: 2 workers per container
- Workers handle PDF generation in parallel

### Memory Management

Node.js memory settings are optimized for container environments:

- `--max-old-space-size=1536`: Prevents memory issues in containers
- Aligned with container memory limits

## Security Considerations

1. **Credentials in a Secret**: The admin password and cookie secret are required and stored in a Secret. Prefer `auth.existingSecret` so they are not kept in values files.
2. **Network isolation**: Chrome loads any http(s) URL a template references. The default NetworkPolicy blocks egress to cloud metadata endpoints (`169.254.169.254`, Azure `168.63.129.16`), link-local and private networks, so templates cannot be used to query instance metadata or internal services. NetworkPolicies require a CNI plugin that enforces them. On AWS, also require IMDSv2 with a hop limit of 1 on the nodes.
3. **Restrict who can reach jsreport**: Use `networkPolicy.ingress.from` to allow only the ingress controller and the services that call the API.
4. **Sandboxed user code**: `trustUserCode` is `false`, so templates and scripts cannot import arbitrary modules and Chrome cannot read local files. Only enable it if every template author is trusted.
5. **No Kubernetes API access**: The service account token is not mounted.
6. **Container hardening**: Runs as the image's non-root `jsreport` user (UID 2500) with all capabilities dropped, no privilege escalation and the `RuntimeDefault` seccomp profile. Chrome runs with `--no-sandbox`, so these settings are the isolation boundary.
7. **CORS disabled**: Cross-origin browser requests are rejected unless `cors.enabled` is set.
8. **Enable HTTPS**: Use TLS on the ingress for production deployments. The Studio UI is served on the same host as the API, so restrict access to it at the ingress if it should not be public.
9. **Resource Limits**: Keep resource limits set to prevent resource exhaustion.

## Troubleshooting

### Common Issues

1. **Pod not starting**: Check resource limits and node capacity
2. **Chrome crashes**: Ensure the `--no-sandbox` flag is set in chrome launch options
3. **Authentication issues**: Verify the `auth` values or the Secret referenced by `auth.existingSecret`
4. **Reports cannot load internal resources**: The NetworkPolicy blocks private networks; add an `networkPolicy.egress.extraEgress` rule
5. **Memory issues**: Increase memory limits for resource-intensive reports

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l "app.kubernetes.io/name=jsreport"

# View pod logs
kubectl logs -l "app.kubernetes.io/name=jsreport"

# Describe pod for events
kubectl describe pod <pod-name>

# Check service
kubectl get svc jsreport
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

### Testing the Chart

```bash
# Lint the chart
helm lint charts/jsreport --values charts/jsreport/ci/lint-values.yaml

# Run unit tests (requires the helm-unittest plugin)
helm plugin install https://github.com/helm-unittest/helm-unittest.git
helm unittest charts/jsreport

# Template the chart
helm template jsreport charts/jsreport --values charts/jsreport/ci/lint-values.yaml

# Install in test mode
helm install jsreport charts/jsreport --values charts/jsreport/ci/lint-values.yaml --dry-run --debug
```

## License

This Helm chart is licensed under the [MIT License](LICENSE).

## Support

- [JSReport Documentation](https://jsreport.net/learn)
- [JSReport GitHub](https://github.com/jsreport/jsreport)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
