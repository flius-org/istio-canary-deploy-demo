apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: hello-app-dr
spec:
  host: hello-app-svc
  subsets:
  - name: v1
    labels:
      version: ${HELLO_APP_V1_VERSION}
  - name: v2
    labels:
      version: ${HELLO_APP_V2_VERSION}
