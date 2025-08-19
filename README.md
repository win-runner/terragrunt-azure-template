# Introduction

This repository contains the infrastructure as code (IaC) for managing cloud resources using Terragrunt and Terraform.\
Terragrunt is a thin wrapper for Terraform that provides extra tools for keeping configurations DRY (Don't Repeat Yourself) and managing remote state.

## Repository Structure

The repository is organized into the following main directories:

- **Root**: Contains global HCL files.
  - `root.hcl`: Global configuration for remote backend state, providers, and global Terraform inputs.
  - `utils.hcl`: Helpers or helper variables.
  - `units.hcl`: Defines the general resource name prefix, source, version, and mock outputs for deployable resources.
    - **Resource name prefix**:
      - This is a standardized prefix that is applied to all resource names. It helps in identifying and organizing resources easily.
    - **Source**:
      - This specifies the location of the module's source code. It can be a local path, a Git repository, or a Terraform Registry URL.
    - **Version**:
      - This indicates the version of the module to be used. Versioning helps in maintaining consistency and avoiding breaking changes when the module is updated.
    - **Mock Outputs**:
      - These are predefined outputs used for testing and validation purposes. They allow you to simulate the behavior of the module without deploying actual resources.
  - `tags.hcl`: Global tags.

- **_envcommon Directory**: Shared configuration and default values for units, and helpers.

- **env**: Contains the environments/projects. For example:
  - `dev`: Development environment configurations.
    - `westeurope`: Region-specific configurations.
      - `001`: Instance-specific configurations.
        - `resourcegroup`: Modules for managing Azure resource groups.
          - `network`: Module for specific resources within the resource group.

This structure allows for clear separation of environments, regions, and instances, making it easier to manage and deploy infrastructure changes.

## Essential Modules

This template includes the following essential modules, which are mandatory for many, if not all, deployments in Azure:

### Resource Group

- [terraform-azapi-resource-group](https://github.com/win-runner/terraform-azapi-resource-group)
- ...

## Run locally

### Install prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

### Authentication

#### Using Personal Access Token (PAT) for Private Repositories

Remember to encode `username:pat` using Base64. Then, use the encoded string in place of `<your_PAT>`.

```bash
git config --global http.https://<PATH>.extraheader "Authorization: Basic <your_PAT>"
```

#### Using Credential Manager for Public Repositories

- [git-credential-manager](https://github.com/git-ecosystem/git-credential-manager)

### Deployment

Login into Azure

```bash
az login
```

Plan environment `dev` in `westeurope` for instance `001`

```bash
cd env/dev/westeurope/001
terragrunt run-all plan --terragrunt-non-interactive
```

Apply with

```bash
terragrunt run-all apply --terragrunt-non-interactive
```

For running single modules, you can also run `terragrunt plan` or `terragrunt apply` directly like so

```bash
cd env/dev/westeurope/001/resourcegroup/network
terragrunt plan
terragrunt apply
```

## Azure DevOps Pipeline

The Azure DevOps Pipeline is defined in the `.azure` folder located in the root directory.\
This pipeline automates the deployment process and ensures that infrastructure changes are consistently applied across different environments.

### Pipeline Configuration

The pipeline configuration is setup to use the two main files `terragrunt-plan.yml` and `terragrunt-apply.yml`.

- `terragrunt-plan.yml`: Pipeline for the planning phase in the specific environment. Generates and validates Terraform plans.
- `terragrunt-apply.yml`: Pipeline for the apply phase in the specific environment. Applies Terraform changes.

The templates under .azure/pipelines/templates/ include reusable tasks and structures:

- `terragrunt-template.yaml`: A central template that provides the logic for plan and apply. It is referenced and parameterized by all environments.
- `install-terraform.yaml`: Installs the required Terraform version.
- `install-terragrunt.yaml`: Installs the required Terragrunt version.
- `configure-azure.yaml`: Configures Azure CLI with the required credentials and permissions.
- `configure-git.yaml`: Sets up Git for authentication and repository access.
- `config.yaml`: Contains variables and environment-specific configuration values (e.g., git token, versions).

### Steps to Run the Pipeline

1. Navigate to the Azure DevOps portal and select the project associated with this repository.
2. Go to the Pipelines section and create a new pipeline.
3. Choose the repository containing the `.azure` folder.
4. Select the `terragrunt-plan.yml` or `terragrunt-apply.yml` file to configure the pipeline.
5. In the review step, select the `Variables` button to add environment variables to the pipeline.\
Here, you need to define the `AZ_GIT_TOKEN_B64` and `ENV_WORKING_DIR` environment variables.\
For the token, use a Base64-encoded Personal Access Token (PAT). The working directory you choose depends on the environment for which you are creating the pipeline (e.g., `env/dev`, `env/stg`, `env/prd`).
6. Save and run the pipeline.
