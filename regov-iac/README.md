# IaC Assignment - ReGov

To achieve the described infrastructure using AWS CDK or Terraform, the script should address the following components:

1. Development Components: CodeCommit, CodeBuild, CodePipeline.
2. Batch Job Components: Amazon ECR, Amazon ECS Fargate, Amazon S3, CloudWatch.
3. Code Deployment from GitHub to ECR.

## Steps:
1. Components:
	1. Configuring our provider `aws` in the region `ap-south-1`.
	2. Creating S3 bucket, ECR repo, CodeCommit repo.
2. Roles:
	1. After creating the components, we move on to creating IAM roles required for CodeBuild with an assume role policy allowing `codebuild.amazonaws.com` to assume the role.
	2. Followed by creating IAM role policy attachment which attaches the `AmazonEC2ContainerRegistryPowerUser` policy to the CodeBuild role, giving it permissions to interact with ECR.
3. CodeBuild Project:
	1. Moving on with creating our CodeBuild project resouce which pulls source code from the CodeCommit repository, builds a Docker image, and pushes it to the ECR repository.
4. CodePipeline:
	1. After that, we'll move to create the required CodePipeline with 2 stages:
		1. **Source** stage pulls the code from the CodeCommit repository.
		2. **Build** stage uses the CodeBuild project to build the Docker image.
5. ECS Cluster:
	1. Now, we're creating an ECS cluster named `my-cluster` with a task definition which defines an ECS task that runs a container from the latest image in the ECR repository, using Fargate as the launch type.
	2. This ECS Task definition needs an ECS service to be initialized to run the task defined above in the specified subnets.
6. CloudWatch:
	1. Our infrastructure needs observability to be implemented in the ECS Fargate cluster.
		2. We conclude by creating a CW Metric Alarm that triggers if the CPU utilization of the ECS service exceeds 80%. This can be setup to autoscale the Fargate in the future.
## Conclusion:
	Our TF file sets up a complete CI/CD pipeline with CodePipeline and CodeBuild, stores the built Docker images in ECR, deploys the images to an ECS cluster, and sets up monitoring with CloudWatch.