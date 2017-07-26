# CI/CD AWS Demo

##### Purpose

The purpose of this repository is to demonstrate a CI/CD pipeline using AWS CloudFormation, Jenkins and Docker.

The scripts and templates within create an AWS CloudFormation stack with:

- a VPC with 1 public subnet
- an EC2 instance with Jenkins and a Docker daemon running as services
- an ECS Repository
- security groups, roles and additional supporting resources

The end-product is an ECS Repository Docker image with a simple "Hello World!" Java web server running on port 8080. After creating the CloudFormation stack and a minimal Jenkins configuration, you will have a working Jenkins multibranch pipeline that builds the Docker image and pushes it to an ECS repository. This image could be used for an ECS cluster or in an Elastic Beanstalk Docker integration.

##### Assumptions

- You must have an AWS account.
- The scripts in this demo are Linux/Mac only.

#### Instructions

1. Fork the [repository](https://github.com/ctacdev/ci_cd_aws_demo) and then clone it to your local machine.

2. In your AWS console, create an EC2 key pair called "CiCdDemoKey" and save it as "CiCdDemoKey.pem" in the project directory.

3. Create the AWS CloudFormation stack defined in *stack.yml*:

`./stack.sh --create-stack`

4. Wait for the stack to complete (optional):

`./stack.sh --wait-for-stack`

The script will save the initial jenkins admin password in *initialJenkinsAdminPassword*.

When the script finishes, it will attempt to open Jenkins in the default browser.

You can also open Jenkins later, by running `./stack.sh --open-jenkins`.

5. Setup Jenkins

1) Run `./stack.sh --open-jenkins` to open Jenkins in the browser. The Jenkins URL is also echoed to the terminal.

2) When presented with the **Unlock Jenkins** page, enter the value in the *initialJenkinsAdminPassword* file.

3) On the next page, click "Install Suggested Plugins".

4) On the next page, click "Continue as Admin" at the bottomn.

5) Click "Start using Jenkins".

6) Click "New Item" from the left navigation menu.

7) Enter "CI CD Demo" for the item name. Select "Multibranch Pipeline" for the project type. Click "OK".

8) Under "Branch Sources", click "Add source" and choose "Git". Enter the HTTPS link to your repository.

9) Under "Scan Multibranch Pipeline Triggers", check "Periodically if not otherwise run".

10) Click "Save".

- You can delete the stack by running `./stack.sh --delete-stack`.

