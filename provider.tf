trigger:
  branches:
    include:
      - feature/resource-group

pool:
  vmImage: ubuntu-latest

stages:

- stage: CI
  displayName: Terraform CI

  jobs:
  - job: TerraformCI
    displayName: Terraform Validation and Plan

    steps:

    - script: |
        TERRAFORM_VERSION="1.15.5"

        echo "Installing Terraform ${TERRAFORM_VERSION}"

        curl -fsSL \
          https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
          -o terraform.zip

        unzip -o terraform.zip

        sudo mv terraform /usr/local/bin/terraform

        terraform version
      displayName: Install Terraform

    - script: |
        terraform init
      displayName: Terraform Init

    - script: |
        terraform fmt -check -recursive
      displayName: Terraform Format Check

    - script: |
        terraform validate
      displayName: Terraform Validate

    - task: AzureCLI@2
      displayName: Terraform Plan
      inputs:
        azureSubscription: 'terraform-azure-connection'
        scriptType: bash
        scriptLocation: inlineScript
        inlineScript: |
          echo "Checking Azure login..."
          az account show

          echo "Running Terraform Plan..."
          terraform plan