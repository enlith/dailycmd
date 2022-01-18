brew install minikube
minikube config set cpus 6
minikube config set memory 12g
minikube start --kubernetes-version=v1.22.2 --driver=hyperkit --container-runtime=docker
eval $(minikube -p minikube docker-env)

echo "minikube pause"
echo "minikube unpause"
echo "minikube mount /localfolder:/test"
echo "docker ... -v /test:/insider/ "
