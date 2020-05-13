# End to End Automated Development to Deployment Setup
## About ##
The objective of this assignment it to create an end to end automated pipeline. Whenever the developer makes the changes to a branch (in our case dev) or master branch, the code is commited then pushed to github, pulled from github by testing team, verify changes, and approve the code for deployment on production server. This is a tedious and error prone task. To automate the complete flow of code from development to testing to deployment on production server we have setup the following infrastructure using **Jenkins**, **Docker** and **Git**, **Github**.

_**Assumptions**_
* Jenkins and Docker are already installed in RHEL8 OS
* Jenkins is added in the sudoers list
* User has a github account setup and git bash installed on the development system

### PART-1 Setting up local workspace (git) and remote repository (github)

* Create a workspace in any desired location.

* Create a file index.html and enter some code in that file.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(17).png)


* Open git bash in the current workspace. WE have our files here.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(16).png)


* Create a branch dev and switch to that branch as following:

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(19).png)


* Edit some code in this branch.

* Create file in the folder .git/hooks by the name of &quot;post-commit&quot; which is known as the post commit hook and add the following lines of code:

```bash
#! /bin/bash
git push
```

* Add the remote repository as origin:
```bash
git remote add origin https://github.com/kartikay1506/devops-training
```

*  Add all the files in dev branch to staging area and commit using the following code:
```bash
git add \*
git commit -m "First Commit"
```
_As soon as the code is committed it will automatically be pushed to github repository by the post commit hook we created in step 6_

* We can now see that our repository is updated and has two branches: master and dev

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(29).png)




### PART -2 Setting Up Jenkins
**Job 1 will setup a production server that will be pulling the code from the master branch of the linked repository which will be triggered after the Quality team verifies the changes made in the dev branch.**


* Give Job name &quot;master-job&quot;.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(2).png)


* Add the link of the github repository created before.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(3).png)


* Select &quot;Trigger builds remotely&quot; to build the job through remote trigger and save the auth token for later use.

As soon as the developer will commit the code on master branch this job will be triggered using the url _**host_ip:8080/job/master-job/build/?token=Auth_Token**_ and the code will be deployed on the production server.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(4).png)


* Add the following script to be executed on the host while the job is being build.
This script will check for a docker container with name &quot;master-docker&quot; and if not found it will deploy one container with the configuration and copy whatever data it pulled from the master branch into the folder _**/home/aws/kartikay/master**_ which will later be mounted on the production server container.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(9).png)




**Job 2 will setup a test server that will be pulling the code from the dev branch of the linked repository and will be triggered after the developer commits the code in the dev branch.**


* Give Job name &quot;dev-job&quot;.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(11).png)


*  Add the link of the github repository created before and select dev as the branch to be used.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(12).png)


*  Select &quot;Trigger builds remotely&quot; to build the job through remote trigger and save the auth token for later use.

As soon as the developer will commit the code on dev branch this job will be triggered using the url _**host_ip:8080/job/dev-job/build/?token=Auth_Token**_ and the code will be deployed on the testing server.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(13).png)


* Add the following script to be executed on the host while the job is being build.
This script will check for a docker container with name &quot;dev-docker&quot; and if not found it will deploy one container with the configuration and copy whatever data it pulled from the dev branch into the folder _**/home/aws/kartikay/dev**_ which will later be mounted on the testing server container.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(14).png)




**Job 3 will be triggered when the Quality team has verified the code and triggerd this job through the remote build trigger. This Job will merge the dev branch and the master branch,  after merging it will trigger Job 1.**


* Give Job name &quot;dev-test-job&quot;.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(22).png)


* Add the link of the github repository created before and select dev as the branch to be used for merging with the master branch.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(23).png)


* Select &quot;Trigger builds remotely&quot; to build the job through remote trigger and save the auth token for later use.

As soon as the Quality team will verify the code on dev branch, they will trigger this job using the url _**host_ip:8080/job/dev-test-job/build/?token=Auth_Token**_.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(24).png)


* Now add post build action that will merge the branch with master branch when the test team will trigger this job upon verifying the changes in the dev branch and as soon as this job is build successfully, the dev branch will be merged with master branch and Job 1 will be triggered for deploying the verified code on the production server.

![](https://github.com/kartikay1506/devops-trainin-assignment/blob/master/images/2020-05-06%20(26).png)
