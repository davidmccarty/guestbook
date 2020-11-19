# guestbook: an example application and helm chart

## Building the application
The application code and build files are in the /src folder  
```sh
cd src
docker build -t guestbook:latest .
docker tag guestbook:latest davidmccarty/guestbook:1.0.0
docker push davidmccarty/guestbook:1.0.0
```

## Building the helm charts

## Creating a helm repository
You can use gh-pages in github to build a helm repository.  
To create a helm repo in github and push your release there you need to setup a separate git repo (see https://helm.sh/docs/topics/chart_repository/ for details).   
The following steps explain how to do this using the git repo called davidmccarty/guestbook-helm as an example.
```sh
# Go to github and create a new repository then clone it e.g. 
git clone https://github.com/davidmccarty/guestbook-helm.git

# Repo uses github pages so you need to create gh-pages branch and set this as project default
cd guestbook-helm
git checkout -b gh-pages
helm3 package ../guestbook-helm-chart -d .
# Set the URL using the github pages settings from your project on github
helm3 repo index guestbook-helm/ --url https://davidmccarty.github.io/guestbook-helm/
cd guestbook-helm
# commit and push changes
git add all
git commit -a -m 'commit message'
git push
# test
curl https://davidmccarty.github.io/guestbook-helm/index.yaml
# Add registry to your helm3
helm3 repo add guestbook-helm https://davidmccarty.github.io/guestbook-helm
helm3 repo update
helm3 repo list
```
Then testthat you can install to a cluster using the helm chart
```sh
# Install the chart directly to a cluster
helm3 install guestbook-demo guestbook-helm/guestbook
# NAME: guestbook-demo
# LAST DEPLOYED: Fri Nov 13 16:07:23 2020
# NAMESPACE: guestbook
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
oc get all
helm3 delete guestbook-demo
```


### Standalone helm chart
The standalone helm chart deploys only the standard kubernetes deployments and services to support a single instance of the application. It does not incluse any of the MCM specific wrappers for deployables, channels etc.   
This can be used to test that there are no environment issues with the target cluster(s) and can be used to illustrate the traditional way of managing application installs as helm releases.
The helm chart is defined in folder /guestbook-helm-chart  
If you want to build and manage your own image then update the values.yaml
```yaml
# Values
image: davidmccarty/guestbook:1.0.0
replicaCount: 2
service:
  type: LoadBalancer
  port: 3000
redis:
  port: 6379 
  slaveEnabled: true
```
To build a release
```sh
cd guestbook
helm3 package guestbook-helm-chart -d guestbook-helm
# Successfully packaged chart and saved it to: guestbook-releases/guestbook-1.0.0.tgz
```
To update the helm repo index.yaml from the project root folder
```sh
helm3 repo index guestbook-helm --url https://davidmccarty.github.io/guestbook-helm/
```
Then commit and push the repo
```sh
cd guestbook-helm
git add all
git commit -a -m 'commit message'
git push
```

### MCM helm charts
To deploy the guestbook application as an MCM application there are 4 helm charts to build.
- `gbf` for the front end  
- `gbrm` for the redis master  
- `gbrs` for the redis slave  
- `gbapp` for the MCM application components  

Each chart has a values.yaml file that can be edited if you want to change images etc.  

To build the charts and push them to the helm repo (working from the project base folder)
```sh
cd guestbook
helm3 package guestbook-mcm-fe-helm-chart -d guestbook-helm
helm3 package guestbook-mcm-rm-helm-chart -d guestbook-helm
helm3 package guestbook-mcm-rs-helm-chart -d guestbook-helm
helm3 package guestbook-mcm-app-helm-chart -d guestbook-helm
helm3 repo index guestbook-helm --merge --url https://davidmccarty.github.io/guestbook-helm/
```
To update the helm repo index.yaml from the project root folder
```sh
helm3 repo index guestbook-helm --url https://davidmccarty.github.io/guestbook-helm/
```
Then commit and push the repo
```sh
cd guestbook-helm
git add all
git commit -a -m 'commit message'
git push
```

## Install Application using helm charts

### Install helm chart directly to a namespace
```sh
oc login ...
oc new-project guestbook-helm
helm3 install guestbook-demo guestbook-helm/guestbook
oc get all
# Get the enxternal IP and Port from the service called 'frontend '
# NAME           TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)          AGE
# frontend       LoadBalancer   172.21.106.154   169.55.85.18   3000:32053/TCP   29s
# --> http://169.55.85.18:32053/
helm3 delete guestbook-demo
oc delete project guestbook-helm
```
Remember taht this installs the application but it does not wrap it in a managed application CRD.  
  
### Install Managed application
For MCM it is only necessary to install the `gbapp` helm chart. 
```sh
helm3 repo update
oc new-project guestbook-deploy
helm3 install gbapp guestbook-helm/gbapp
``` 
This will create the following:
```sh
o












