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

```bash
# Install with default values
helm install my-jsreport jsreport-helm/jsreport

# Install with custom values
helm install my-jsreport jsreport-helm/jsreport -f my-values.yaml

# Install in a specific namespace
helm install my-jsreport jsreport-helm/jsreport --namespace jsreport --create-namespace

# Install from local chart (for development)
helm install my-jsreport charts/jsreport
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
| `image.tag`                                  | string | `"4.11.0-full"`                                                                                 | JSReport image tag                               |
| `env`                                        | list   | See values.yaml                                                                                | Environment variables for JSReport configuration |
| `imagePullSecrets`                           | list   | `[]`                                                                                           | Image pull secrets                               |
| `nameOverride`                               | string | `""`                                                                                           | Override name of the chart                       |
| `fullnameOverride`                           | string | `""`                                                                                           | Override fullname of the chart                   |
| `serviceAccount.create`                      | bool   | `true`                                                                                         | Create service account                           |
| `serviceAccount.automount`                   | bool   | `true`                                                                                         | Automount service account token                  |
| `serviceAccount.annotations`                 | object | `{}`                                                                                           | Service account annotations                      |
| `serviceAccount.name`                        | string | `""`                                                                                           | Service account name                             |
| `podAnnotations`                             | object | `{}`                                                                                           | Pod annotations                                  |
| `podLabels`                                  | object | `{}`                                                                                           | Pod labels                                       |
| `podSecurityContext`                         | object | `{}`                                                                                           | Pod security context                             |
| `securityContext`                            | object | `{}`                                                                                           | Container security context                       |
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
| `volumes`                                    | list   | `[]`                                                                                           | Additional volumes                               |
| `volumeMounts`                               | list   | `[]`                                                                                           | Additional volume mounts                         |
| `nodeSelector`                               | object | `{}`                                                                                           | Node selector                                    |
| `tolerations`                                | list   | `[]`                                                                                           | Tolerations                                      |
| `affinity`                                   | object | `{}`                                                                                           | Affinity                                         |

### Environment Variables

The chart includes several important environment variables for JSReport configuration:

**Chrome/Puppeteer Configuration:**

- `chrome_launchOptions_args`: Chrome launch options optimized for Kubernetes
- Additional Chrome flags for stability and security

**Authentication Configuration:**

- `extensions_authentication_admin_username`: Admin username (default: "admin")
- `extensions_authentication_admin_password`: Admin password (default: "ChangeMe!Password!")
- `extensions_authentication_cookieSession_secret`: Session secret (default: "ChangeMe!Secret!")

**Performance and Stability Settings:**

- `NODE_ENV`: Set to "production" for optimal performance
- `workers_numberOfWorkers`: Number of worker processes (default: 2)
- `workers_timeout`: Worker timeout in milliseconds (default: 120000)
- `NODE_OPTIONS`: Node.js memory management settings

**⚠️ Important Security Note**: Change the default admin password and session secret in production deployments!

## Examples

### Basic Installation

```bash
helm install jsreport jsreport-helm/jsreport
```

### Production Deployment with Custom Values

Create a `production-values.yaml` file:

```yaml
replicaCount: 3

image:
  tag: "4.9.0-full"

env:
  - name: chrome_launchOptions_args
    value: "--no-sandbox,--disable-dev-shm-usage,--disable-gpu"
  - name: extensions_authentication_admin_username
    value: "admin"
  - name: extensions_authentication_admin_password
    value: "YourSecurePassword123!"
  - name: extensions_authentication_cookieSession_secret
    value: "YourSecureSessionSecret456!"

resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1Gi

# Security settings
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  capabilities:
    drop:
      - ALL
  allowPrivilegeEscalation: false

# Optimized environment variables
env:
  - name: NODE_ENV
    value: "production"
  - name: workers_numberOfWorkers
    value: "2"
  - name: NODE_OPTIONS
    value: "--max-old-space-size=1536"

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

```yaml
# For persistent data storage
volumes:
  - name: jsreport-data
    persistentVolumeClaim:
      claimName: jsreport-pvc
  # Temporary volumes are automatically configured
  - name: tmp-volume
    emptyDir:
      sizeLimit: 1Gi

volumeMounts:
  - name: jsreport-data
    mountPath: /app/data
  - name: tmp-volume
    mountPath: /tmp
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
- Configurable timeout and port ranges

### Memory Management

Node.js memory settings are optimized for container environments:

- `--max-old-space-size=1536`: Prevents memory issues in containers
- Aligned with container memory limits

## Security Considerations

1. **Change Default Credentials**: Always change the default admin username and password in production
2. **Use Strong Session Secrets**: Generate a strong, random session secret
3. **Enable HTTPS**: Use TLS/SSL for production deployments
4. **Resource Limits**: Set appropriate resource limits to prevent resource exhaustion
5. **Security Context**: Configure appropriate security contexts for your environment
6. **Non-Root User**: The chart runs as non-root user (UID 1000) by default
7. **Capability Dropping**: All unnecessary Linux capabilities are dropped

## Troubleshooting

### Common Issues

1. **Pod not starting**: Check resource limits and node capacity
2. **Chrome crashes**: Ensure the `--no-sandbox` flag is set in chrome launch options
3. **Authentication issues**: Verify environment variables are set correctly
4. **Memory issues**: Increase memory limits for resource-intensive reports

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
helm lint charts/jsreport

# Template the chart
helm template jsreport charts/jsreport

# Install in test mode
helm install jsreport charts/jsreport --dry-run --debug
```

## License

This Helm chart is licensed under the [MIT License](LICENSE).

## Support

- [JSReport Documentation](https://jsreport.net/learn)
- [JSReport GitHub](https://github.com/jsreport/jsreport)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
