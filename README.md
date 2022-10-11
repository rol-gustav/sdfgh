# Cronjob template for kubernetes clusters.
Cronjob template for deploying to a kubernetes cluster with autobuilding github action for azure container registry.

```javascript
// index.js
/**
 * @Main entrypoint of the cronjob
 */
const main = () => {
  console.log(process.env.HEJSAN);
}

/** Entrypoint */
main();
```

```yml
auto_build_azure_<env>.yml
---
env:
  AZURE_CONTAINER_PASSWORD: ${{secrets.AZURE_CONTAINER_REGISTRY_PRODUCTION_ADMIN_PASSWORD}}
  AZURE_CONTAINER_SERVER: ${{secrets.AZURE_CONTAINER_REGISTRY_PRODUCTION_SERVER}}
  AZURE_CONTAINER_USERNAME: ${{secrets.AZURE_CONTAINER_REGISTRY_PRODUCTION_ADMIN_USERNAME}}
  IMAGE: # Docker image name that will be generated.
```

```yml
cron.yml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: "<name>" ## Name of the cronjob
  namespace: "<namespace>" ## Name of the namespace that the cronjob should run under
spec:
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: "<name>" ## Name of the cronjob
        spec:
          containers:
          - name: "<name>"  ## Name of the cronjob
            image: "<image>:<tag>" ## Docker image with version tag
            envFrom:
            - secretRef:
                name: application-config-secret
          restartPolicy: Never
  schedule: "* * * * *" ## Schedule, e.g (* * * * *) means run every minute
  successfulJobsHistoryLimit: 10

```

```Dockerfile
# Dockerfile
# Node 14 is used for building the production bundle.
FROM node:14 AS builder

WORKDIR /usr/src/app

COPY package*.json ./

COPY . .

RUN yarn && yarn build # Building the bundle, change if necessary

# Node 14 alpine for minimal production footprint
FROM node:14-alpine as production

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/index.js ./
COPY --from=builder /usr/src/app/src ./src

ENTRYPOINT ["node"]

CMD ["index.js"]
```
