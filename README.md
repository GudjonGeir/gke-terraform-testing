
### Create cluster

Go to `deployment/terraform/gke`
```
terraform init
terraform apply
```

### Configure cluster access

```
gcloud container clusters get-credentials my-test-cluster
```

### Create namespace

```
kubectl create namespace application
```

### Set up Kubernetes Service Account

Go to `deployment/services/dummy`
```
kubectl apply -f ./serviceaccount.yaml
```

### Set up Google Service Account and role bindings

Go to `deployment/terraform/services/dummy-service`
```
terraform init
terraform apply
```

### Deploy service

Go to `deployment/services/dummy`
```
kubectl apply -f ./deployment.yaml
```
