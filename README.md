https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785

## Step 1. Create a Simple Node App

## First, run the following commands to create and navigate to our application’s directory:
$ mkdir node-docker-ecs
$ cd node-docker-ecs

## Next, create an npm project:
$ npm init --y

## Install Express:
$ npm install express
Create an index.js file with the following code:

## The app can then run with this command:
$ node index.js
You should see your app at http://localhost:3000/:

## Build and publish image
# 1. to login to docker ecr
docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) 216952475463.dkr.ecr.us-east-1.amazonaws.com

## 2. build your docker image
docker build -t nashwan .

## 3. After the build completes, tag your image so you can push the image to this repository:
docker tag nashwan:latest 216952475463.dkr.ecr.us-east-1.amazonaws.com/nashwan:latest

## 4. Run the following command to push this image to your newly created AWS repository:
docker push 216952475463.dkr.ecr.us-east-1.amazonaws.com/nashwan:latest

