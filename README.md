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
| `image.tag`                                  | string | `"4.9.0-full"`                                                                                 | JSReport image tag                               |
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
| `resources`                                  | object | `{}`                                                                                           | Resource limits and requests                     |
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

- `chrome_launchOptions_args`: Chrome launch options for PDF generation
- `extensions_authentication_admin_username`: Admin username (default: "admin")
- `extensions_authentication_admin_password`: Admin password (default: "ChangeMe!Password!")
- `extensions_authentication_cookieSession_secret`: Session secret (default: "ChangeMe!Secret!")

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
volumes:
  - name: jsreport-data
    persistentVolumeClaim:
      claimName: jsreport-pvc

volumeMounts:
  - name: jsreport-data
    mountPath: /app/data
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

## Security Considerations

1. **Change Default Credentials**: Always change the default admin username and password in production
2. **Use Strong Session Secrets**: Generate a strong, random session secret
3. **Enable HTTPS**: Use TLS/SSL for production deployments
4. **Resource Limits**: Set appropriate resource limits to prevent resource exhaustion
5. **Security Context**: Configure appropriate security contexts for your environment

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
