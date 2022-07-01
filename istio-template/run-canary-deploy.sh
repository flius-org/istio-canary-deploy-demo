gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GCP_ZONE}

mkdir demo
cp *.yaml demo/

#canary deploy
export HELLO_APP_V1_VERSION=$(kubectl get destinationrules hello-app-dr -ojson | jq -r .spec.subsets[0].labels.version)
echo $HELLO_APP_V1_VERSION
export TAG_NAME=$(date +%y%m%d-%H%M%S)
echo $TAG_NAME
export HELLO_APP_V2_VERSION=${TAG_NAME}
echo $HELLO_APP_V2_VERSION
export HELLO_APP_V2_IMAGE=gcr.io/${PROJECT_ID}/hello-app:${HELLO_APP_V2_VERSION}
echo $HELLO_APP_V2_IMAGE

# #modify main.go
cat main.go.tpl | envsubst > ../golang-template/main.go
cat ../golang-template/main.go
#
cd ../golang-template
gcloud builds submit --substitutions=_PROJECT_ID=${PROJECT_ID},TAG_NAME=${TAG_NAME}

cd ../istio-template
cat destination-rule.yaml.tpl | envsubst > demo/destination-rule.yaml
cat demo/destination-rule.yaml
cat hello-app-deployment-v2.yaml.tpl | envsubst > demo/hello-app-deployment-v2.yaml
cat demo/hello-app-deployment-v2.yaml

kubectl apply -f demo/hello-app-deployment-v2.yaml
kubectl apply -f demo/destination-rule.yaml
kubectl apply -f demo/vs-90-10.yaml
echo "V1: $HELLO_APP_V1_VERSION 90%, V2: $HELLO_APP_V2_VERSION 10%"
sleep 30
kubectl apply -f demo/vs-50-50.yaml
echo "V1: $HELLO_APP_V1_VERSION 50%, V2: $HELLO_APP_V2_VERSION 50%"
sleep 30
kubectl apply -f demo/vs-10-90.yaml
echo "V1: $HELLO_APP_V1_VERSION 10%, V2: $HELLO_APP_V2_VERSION 90%"
sleep 30

# very important
cat destination-rule-single-svc.yaml.tpl | envsubst > demo/destination-rule.yaml
kubectl apply -f demo/destination-rule.yaml
kubectl apply -f demo/vs-100-0.yaml
echo "V1: $HELLO_APP_V2_VERSION 100%, V2 : $HELLO_APP_V1_VERSION 0%"
sleep 30

kubectl delete deploy hello-app-deployment-${HELLO_APP_V1_VERSION}
