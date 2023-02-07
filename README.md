
This repo contains simple Terraform code to create S3 bucket using AWS 'Code Pipeline'. The main purpose of this repo to understand Terraform implementation using AWS 'Code Pipeline'.

# Setup

## Terraform Backend

### Terraform S3 bucket
* Create S3 bucket and accept all the defaults. For example 'vijay-terraform-cicd-test'.

### Terraform DynamoDB
* Create DynamoDB table 'vijay-terraform'. This name can be anything.
* Enter primary key as 'LockID'.
* Accept default settings.


## Code Commit
* Create AWS 'CodeCommit' repo. We will be pushing our Terraform code to this repo. For example 'terraform-cicd-repo'.
	* Enter the name and accept the defaults. 


## Code Pipeline
* Enter Pipeline name. For example 'terraform-cicd'.
* Accept defaults and click 'Next'.
* Select 'AWS CodeCommit' as 'Source' provider from drop down.
	* 'Repository name' :- Choose the repo 'terraform-cicd-repo'.
	* 'Branch name' :- main
	* Accept default for rest and choose 'Next'. 	
* Build :- 
	* 	Build Provider :- AWS CodeBuild
	*  Project Name :- Click on 'Create Project'.
	*  Project Configuration :- 
		* Project Name :- terraform-cicd-build
		* Environment :- 
			*  Environment image :- 
				* Managed 
				* Operating System :- Amazon Linux 2
				* Runtimes :- Standard
				* Image :- aws/codebuild/amazonlinux2-x86_64-standard:4.0  
			*  Privileged :- Enable
			*  Service Role :- New Service Role. Write the 'Service Role Name'.
			*  Additional Configuration :- 
				* VPC :- 
				* Subnets :- Need to select 'Private Subnets'. I am not sure why but 'AWS CodeBuild' EC2 instance needs to run in private subnet.
				* Security Group :- Must allow outbound traffic. 
				* Environment Variables :- 
					* Name :- TF_COMMAND
					* Value :- apply
					* Type :- plaintext 
				*  
		* BuildSpec :- Use a BuildSpec file 
		* Logs :- CloudWatch Logs
		* Click on 'Continue to CodePipeline'. Wait untile 'Code Build Project' is created.  
	*  Now back on 'Code Pipeline' screen, click 'Next'.
	*  Click 'Skip' on 'Add Deploy Stage'. Accept the pop up.
	*  Finally review the configuration and click on 'Create Pipeline'.


## Add policies to 'CodeBuild' IAM Service Role
* Above during creation of 'Code Build Server' we have mentioned 'role'. This role by default contains permissions for 'CodeBuild'. Our Terraform code creates AWS resources, so we need to add additional policies. 
	* In this sample Terraform code, we are creating 'S3' bucket, so Build Server needs access to S3 service. So we add 'S3' policy to the Build Server role. For demo purpose use the 'S3 Full access' managed policy. In realworld you might want to customize the policy. 


## Push the terraform code to CodeCommit Repo.
* Either through command line or manually upload all files in this repo to 'Code Commit' repo created above.
* Once the code is uploaded 'Code Pipeline' runs and Terraform code should execute successfully.


# BuildSpec File
This file is used by BuildServer to download 'Terraform' and install the software. And clone 'CodeCommit' repo and execute 'terraform' 'apply' on the repo.

```sh
version: 0.2

phases:

  install:
    commands:
      - "yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo"
      - "yum -y install terraform"
  pre_build:
    commands:
      - terraform init

  build:
    commands:
      - terraform $TF_COMMAND -auto-approve

  post_build:
    commands:
      - echo terraform $TF_COMMAND completed on `date`
```

