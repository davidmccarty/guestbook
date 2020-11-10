# Steps to recreate

## Deploy the application objects

1. Copy yaml flie from tutorial site https://kubernetes.io/docs/tutorials/stateless-application/guestbook/
  
2. Edit the yaml files to set the correct api version 
    ```yaml
    apiVersion: apps/v1beta2
    ```   
  
3. Create a new project called guestbook
    ```sh
    oc new-project guestbook
    ```

4. Deploy the application
    ```sh
    ./deploy.sh
    ```

5. Get the service endpoint to test the application
    ```sh
    oc get service frontend
    # NAME       TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
    # frontend   LoadBalancer   172.21.63.119   159.8.154.132   80:30429/TCP   22m
    ```
    use the external ip and port e.g.  
    http://159.8.154.132:30429

## Use MCM to build the application definition

1. In MCM go to `Manage Applications` 
2. Add a `new application from resources`
3. In the search bar use `namespace=guestbook`
4. Select the 3 deployments and the 3 services to create the application
5. Save as `guestbook-application`in namespace `guestbook`
6. Use `edit` to review the yaml (saved here as application.yaml)