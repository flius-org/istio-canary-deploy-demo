apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app-deployment-${HELLO_APP_V1_VERSION}
spec:
  selector:
    matchLabels:
      greeting: hello
      version: ${HELLO_APP_V1_VERSION}
  replicas: 3
  template:
    metadata:
      labels:
        greeting: hello
        version: ${HELLO_APP_V1_VERSION}
    spec:
      containers:
      - name: hello-app
        image: ${HELLO_APP_V1_IMAGE}
