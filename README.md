# ReGov CI/CD

## Overview
1. To setup a four (4) stages CI/CD pipeline. The stages (e.g Dev,QA,UAT,Prod) should have manual approvals.
	    - Terraform
	    - Github Actions / Jenkins
	    - SonarQube (optional)
		    - This wasn't possible because it needed an active sonarqube server for testing the setup, so the previous iteration was discarded by me.
## Repository Structure

- **`/terraform`**: Directory containing Terraform configurations.
  - `/dev`: Terraform configurations for the development environment.
  - `/qa`: Terraform configurations for the QA environment.
  - `/uat`: Terraform configurations for the UAT environment.
  - `/prod`: Terraform configurations for the Prod environment.

- **`.github/workflows`**: GitHub Actions workflows exists here.
  - `dev-pipeline.yml`: Workflow for the development environment.
  - `qa-pipeline.yml`: Workflow for the QA environment.
  - `uat-pipeline.yml`: Workflow for the UAT environment.
  - `prod-pipeline.yml`: Workflow for the production environment.

- **Source code.**
  - `./app.js`: Main application code.

- **Useful scripts.**
  - `deploy.sh`: Deployment script used in workflows.

## GitHub Actions Pipelines

Setting up GitHub Actions involves several important steps. In this section, we'll walkthrough each step in detail.
### Pipeline Flow:

This begins by checking out the code, setting up Node.js, installing dependencies, and building the project. AWS credentials are configured for Terraform, which is then initialized and used to plan infrastructure changes. If it requires manual approval, Terraform applies the planned changes, and a deployment script is executed to complete the deployment to the production environment.

*==Note: All the workflows require manual approval except dev pipeline as it is triggered manually in the first place, or can be triggered manually.==*

## Terraform Configurations

The terraform setup basically consists of the **main.tf**. It sets up the EC2 instance from an Ubuntu AMI with the respective security group in the `ap-south-1` region. The security group allows Port 80, 443, and 22. The spec of the machine depends on the environments, only the prod system deserves the higher spec. The systems are tagged for better visibility.

