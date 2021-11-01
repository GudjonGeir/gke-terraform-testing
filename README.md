
### Create vpc

Go to `deployment/terraform/vpc`
```
terraform init
terraform apply
```

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


### Provision resources for the service

Go to `deployment/terraform/services/dummy-service`
```
terraform init
terraform apply
```

Change the service's database user password:
```
gcloud sql users set-password dummy-service \
--instance=dummy-db \
--prompt-for-password
```

### Deploy service

Go to `deployment/services/dummy`
```
kubectl create namespace application
kubectl apply -f ./deployment.yaml
kubectl apply -f ./serviceaccount.yaml
```

Create secrets for service
```
kubectl -n application create secret generic dummy \
  --from-literal=db-password='<PASSWORD>'
```

### Verify connection

Connect to pod
```
kubectl exec -it deploy/dummy-service \
    --namespace application -- /bin/bash
```

Install psql
```
apt-get update
apt-get install postgresql-client
````

Connect to database
```
psql "host=127.0.0.1 sslmode=disable dbname=postgres user=dummy-service"
```
