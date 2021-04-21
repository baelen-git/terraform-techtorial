# Install Jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install -f ./jenkins_values.yaml jenkins jenkins/jenkins --version 3.1.2

# Expose the Service Externally
kubectl expose pod jenkins-0 --type=LoadBalancer --port=8080
TARGET=$(minikube service --url jenkins-0 | cut -f3- -d "/")
sudo nohup socat TCP-LISTEN:8080,fork TCP:$TARGET &

# Return Jenkins username and Password
export JENKINS_USERNAME="admin"
export JENKINS_PASSWORD="$(kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)"
export IP="$(ifconfig ens160 | grep 'inet ' | awk '{print $2}')"
echo "Username: $JENKINS_USERNAME"
echo "Password: $JENKINS_PASSWORD"
echo "URL: http://$IP:8080"