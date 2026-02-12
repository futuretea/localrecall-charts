# LocalRecall Helm Chart

A Helm chart for deploying [LocalRecall](https://github.com/mudler/LocalRecall) - a lightweight RESTful API for managing knowledge bases in vector databases.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- An external PostgreSQL database (with TimescaleDB, pgvector, and pgvectorscale extensions)

## Installation

### Add the repository (if using a chart repository)

```bash
helm repo add localrecall https://your-chart-repo.example.com
helm repo update
```

### Install the chart

```bash
# Install with default values (requires external PostgreSQL)
helm install localrecall localrecall/localrecall \
  --set postgresql.external.host=your-postgres-host \
  --set postgresql.external.password=your-password

# Or install from local directory
helm install localrecall ./deploy/charts/LocalRecall \
  --set postgresql.external.host=your-postgres-host \
  --set postgresql.external.password=your-password
```

### Example: Deploy with external PostgreSQL

```bash
helm install localrecall ./deploy/charts/LocalRecall \
  --set postgresql.external.host=postgresql.database.svc.cluster.local \
  --set postgresql.external.port=5432 \
  --set postgresql.external.database=localrecall \
  --set postgresql.external.username=localrecall \
  --set postgresql.external.password=securepassword \
  --set config.openai.baseUrl=http://localai:8080 \
  --set config.openai.apiKey=sk-1234567890
```

## Configuration

The following table lists the configurable parameters of the LocalRecall chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `""` |

### LocalRecall Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | LocalRecall image registry | `quay.io` |
| `image.repository` | LocalRecall image repository | `mudler/localrecall` |
| `image.tag` | LocalRecall image tag | `v0.5.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Docker registry secret names | `[]` |

### Deployment Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of LocalRecall replicas | `1` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full name | `""` |

### LocalRecall Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.vectorEngine` | Vector database engine (chromem or postgres) | `postgres` |
| `config.embeddingModel` | Embedding model name | `granite-embedding-107m-multilingual` |
| `config.maxChunkingSize` | Maximum size for document chunks | `400` |
| `config.chunkOverlap` | Overlap between chunks | `0` |
| `config.hybridSearch.bm25Weight` | BM25 keyword search weight | `0.5` |
| `config.hybridSearch.vectorWeight` | Vector similarity search weight | `0.5` |
| `config.openai.apiKey` | API key for embedding service | `sk-1234567890` |
| `config.openai.baseUrl` | Base URL for embedding service | `http://localai:8080` |
| `config.apiKeys` | Comma-separated API keys for authentication | `""` |

### PostgreSQL Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.external.host` | External PostgreSQL host | `postgresql` |
| `postgresql.external.port` | External PostgreSQL port | `5432` |
| `postgresql.external.database` | Database name | `localrecall` |
| `postgresql.external.username` | Database username | `localrecall` |
| `postgresql.external.password` | Database password | `localrecall` |
| `postgresql.external.sslMode` | SSL mode | `disable` |
| `postgresql.external.existingSecret` | Existing secret for credentials | `""` |

### Persistence Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteOnce]` |
| `persistence.size` | Storage size | `10Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service HTTP port | `8080` |
| `service.nodePort` | NodePort (if service.type is NodePort) | `""` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Resource Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `2Gi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `512Mi` |

## PostgreSQL Setup

This chart requires an external PostgreSQL database with the following extensions:
- TimescaleDB
- pgvector
- pgvectorscale (optional, for advanced vector search)
- pg_textsearch (for BM25 search)

You can use the LocalRecall PostgreSQL image which includes all required extensions:

```bash
kubectl run postgresql --image=quay.io/mudler/localrecall:v0.5.2-postgresql \
  --env="POSTGRES_DB=localrecall" \
  --env="POSTGRES_USER=localrecall" \
  --env="POSTGRES_PASSWORD=localrecall"
```

Or deploy using a custom PostgreSQL chart with the required extensions.

## Upgrading

To upgrade an existing release:

```bash
helm upgrade localrecall ./deploy/charts/LocalRecall
```

## Uninstalling

To uninstall/delete the deployment:

```bash
helm uninstall localrecall
```

This will remove all Kubernetes components associated with the chart, except the PersistentVolumeClaim if `persistence.enabled` is true.

## Examples

### Example 1: Deploy with custom embedding service

```bash
helm install localrecall ./deploy/charts/LocalRecall \
  --set config.openai.baseUrl=http://my-embedding-service:8080 \
  --set config.openai.apiKey=my-api-key \
  --set config.embeddingModel=my-embedding-model
```

### Example 2: Deploy with API authentication

```bash
helm install localrecall ./deploy/charts/LocalRecall \
  --set config.apiKeys="key1,key2,key3"
```

### Example 3: Deploy with custom chunk settings

```bash
helm install localrecall ./deploy/charts/LocalRecall \
  --set config.maxChunkingSize=1000 \
  --set config.chunkOverlap=100
```

### Example 4: Deploy with ingress

```bash
helm install localrecall ./deploy/charts/LocalRecall \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=localrecall.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

## Support

For more information about LocalRecall:
- GitHub: https://github.com/mudler/LocalRecall
- Issues: https://github.com/mudler/LocalRecall/issues
