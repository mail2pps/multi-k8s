#!bash
#build all images
docker build -t mail2pps/multi-client:latest  -t mail2pps/multi-client:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t mail2pps/multi-server:latest  -t mail2pps/multi-server:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t mail2pps/multi-worker:latest  -t mail2pps/multi-worker:$GIT_SHA -f ./worker/Dockerfile ./worker

#push all images to docker hub
docker push mail2pps/multi-client:latest
docker push mail2pps/multi-server:latest
docker push mail2pps/multi-worker:latest
docker push mail2pps/multi-client:$GIT_SHA
docker push mail2pps/multi-server:$GIT_SHA
docker push mail2pps/multi-worker:$GIT_SHA

#apply kube configs
kubectl apply -f k8s
#imperatively set latest images
kubectl set image deployments/server-deployment server=mail2pps/multi-server:$GIT_SHA #or kubectl rollout restart deployment/server-deployment
kubectl set image deployments/client-deployment client=mail2pps/multi-client:$GIT_SHA #or kubectl rollout restart deployment/client-deployment
kubectl set image deployments/worker-deployment worker=mail2pps/multi-worker:$GIT_SHA #or kubectl rollout restart deployment/worker-deployment

#make sure to run below imperative command before deploy to GCP
	#kubectl create secret generic pgpassword --from-literal PGPASSWORD=xyz
#make sure to Install nginx-ingress in gcp
	#https://kubernetes.github.io/ingress-nginx/deploy/#using-helm and https://helm.sh/docs/intro/install/ (search for : From Script)
	#Install Helm v3:
		# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
		# chmod 700 get_helm.sh
		# ./get_helm.sh
	#(Skip for v3 of helm)Service Account / RBAC setup
		# kubectl create serviceaccount --namespace kuber-system tiller
		# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller	
	#Install Ingress-Nginx:
		#helm repo add stable https://kubernetes-charts.storage.googleapis.com/
		#helm install my-nginx stable/nginx-ingress --set rbac.create=true