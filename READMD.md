## Usage
```bash
helm repo add hoon https://yanghoon.github.io/charts
helm search argo-app
NAME          	CHART VERSION	APP VERSION	DESCRIPTION                        
hoon/argo-app 	0.3.1        	1.5.5      	A Helm chart for ArgoCD Application

helm install hoon/argo-app -f values.yaml -n test --dry-run --debug

```
## Test
```bash
helm template . -f values-test.yaml -n test
```