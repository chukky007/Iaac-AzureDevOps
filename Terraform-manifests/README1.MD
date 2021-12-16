---
title: Azure IaC DevOps for Terraform Project
description: Create Azure IaC DevOps for Terraform Project
---

## Step-00: Introduction
### Build Pipeline - CI
- Implement Build Pipeline (Continuous Integration Pipeline)
- Use `CopyFiles` and `PublishArtifacts` Tasks in Build Pipeline
### Release Pipelines - CD
- Implement Deployment stages `Dev, QA, Stage and Prod`
- In each stage implement below listed Tasks for a `Ubuntu Agent`
  - terraform install 
  - terraform init
  - terraform validate
  - terraform plan
  - terraform apply -auto-approve
- Test both CI CD Pipelines  

## Step-02: Create Github Repository and Check-In Files
### Step-02-01: Create new github Repository
- **URL:** github.com
- Click on **Create a new repository**
- **Repository Name:** terraform-on-azure-with-azure-devops
- **Description:** Terraform on Azure with Azure IaC DevOps
- **Repo Type:** Public / Private
- **Initialize this repository with:**
- **CHECK** - Add a README file
- **CHECK** - Add .gitignore 
- **Select .gitignore Template:** Terraform
- **CHECK** - Choose a license  (Optional)
- **Select License:** Apache 2.0 License
- Click on **Create repository**

## Step-02-02: Clone Github Repository to Local Desktop
```t
# Clone Github Repo
git clone https://github.com/<YOUR_GITHUB_ID>/<YOUR_REPO>.git
```

## Step-02-03: Copy files from Git-Repo-Files folder to local repo & Check-In Code

- **Source Location:** Git-Repo-Files
- **Destination Location:** Copy all folders and files from `Git-Repo-Files` newly cloned github repository folder in your local desktop
- **Check-In code to Remote Repository**
```t
# GIT Status
git status

# Git Local Commit
git add .
git commit -am "First Commit"

# Push to Remote Repository
git push

# Verify the same on Remote Repository
https://github.com/<YOUR_GITHUB_ID>/<YOUR_REPO>.git
```

## Step-04: Create Azure DevOps Organization
### Step-04-01: Create Azure DevOps Organization
- Navigate to `https://dev.azure.com`
- Click on `Sign in to Azure DevOps`
- Provide your Azure Cloud admin user
  - Username: XXXXXXXXXXXXXX
  - Password: XXXXXXXXXXXXXX
- Click on create **New Organization**
- **Name your Azure DevOps organization:** 
- **We'll host your projects in:** Choose the location (Azure selects based on current location where you are accessing from)
- **Enter the characters you see:** 
- Click on **Continue**


## Step-05: Install Terraform Extension for Azure DevOps
- [Terraform Extension for Azure DevOps](

## Step-06: Create New Project in Azure DevOps Organization
- Create a New Project in Azure DevOps Organization newly created
- Click on **New Project**
- **Project Name:** 
- **Description:** 
- **Visibility:** Private
- Click on **Create**
- Pipeline Hierarchial Flow: `Stages -> Stage -> Jobs -> Job -> Steps -> Task1, Task2`

## Step-07: Create Azure CI (Continuous Integration) Pipeline (Build Pipeline)
- Go to  Azure DevOps -> Organization (stacksimplify1) -> Project (terraform-on-azure-with-azure-devops) -> Pipelines -> Pipelines
- Click on **New Pipeline**
- **Where is your code?:** GitHub
- Follow browser redirect steps to integrate with Github Account
- **Select a repository:** 
- **Configure your pipeline:** Starter Pipeline
- Rename the Pipeline file name 
- Build the below code using two tasks listed below
  - Copy Files
  - Publish Artifacts
- Click on **Save and Run** to Run the pipeline  
```yaml
trigger:
- main

# Stages
# Stage-1:
  # Task-1: Copy terraform-manifests files to Build Artifact Directory
  # Task-2: Publish build articats to Azure Pipelines
# Pipeline Hierarchial Flow: Stages -> Stage -> Jobs -> Job -> Steps -> Task1, Task2, Task3  

stages:
# Build Stage 
- stage: Build
  displayName: Build Stage
  jobs:
  - job: Build
    displayName: Build Job
    pool:
      vmImage: 'ubuntu-latest'
    steps: 
## Publish Artifacts pipeline code in addition to Build and Push          
    - bash: echo Contents in System Default Working Directory; ls -R $(System.DefaultWorkingDirectory)        
    - bash: echo Before copying Contents in Build Artifact Directory; ls -R $(Build.ArtifactStagingDirectory)        
    # Task-2: Copy files (Copy files from a source folder to target folder)
    # Source Directory: $(System.DefaultWorkingDirectory)/terraform-manifests
    # Target Directory: $(Build.ArtifactStagingDirectory)
    - task: CopyFiles@2
      inputs:
        SourceFolder: '$(System.DefaultWorkingDirectory)/terraform-manifests'
        Contents: '**'
        TargetFolder: '$(Build.ArtifactStagingDirectory)'
        OverWrite: true
    # List files from Build Artifact Staging Directory - After Copy
    - bash: echo After copying to Build Artifact Directory; ls -R $(Build.ArtifactStagingDirectory)  
    # Task-3: Publish build artifacts (Publish build to Azure Pipelines)           
    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'terraform-manifests'
        publishLocation: 'Container'  

```
- Verify First Run logs
- Rename the Pipeline name to anything of your choice

## Step-08: Sync Local Git Repo
- A new file  will be added git Remote Repo
- Sync the same thing to your local Git Repo
```t
# Local Git Repo
git pull
```

## Step-09: Create Azure Resource Manager Service Connection for Azure DevOps
- Go to  Azure DevOps -> Organization  -> Project  > Project Settings -> Pipelines -> Service Connections
- Click on **New Service Connection**
- **Choose a service or connection type:** Azure Resource Manager
- **Authentication Method:** Service principal (automatic)
- **Scope level:** Subscription
- **Subscription:** Select Subsciption if we have many
- **Username:** Azure Cloud Admin User
- **Password:** XXXXXXXXX
- **Resource Group:** leave empty
- **Service connection name:** terraformiac1
- **Description (optional):** terraformiac1 Service Connection used for CICD Pipelines
- **Security:** CHECK Grant access permission to all pipelines (leave to default checked)
- Click on **Save**

## Step-10: Create Storage Account for storing Terraform State Files
- Create Storage Account, Storage Container if not created. 
```t
# Terraform State Storage to Azure Storage Container
    resource_group_name   = "terraform-storage-rg"
    storage_account_name  = "terraformstate201"
    container_name        = "tfstatefiles"
    key                   = "dev-terraform.tfstate"
```

## Step-11: Release Pipelines - Create Dev Stage
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Releases
- Click on **New Release Pipeline**
- **Pipeline Name:** Terraform-CD
### Dev Stage
- **Stage Name:** Dev Stage
- **Stage Owner:**  (your-azure-admin-id)
- Click on **1 Job, 0 Task**
#### Agent Job
- **Display Name:** Terraform Ubuntu Agent
- **Agent Pool:** Azure Pipelines
- **Agent Specification:** Ubuntu latest image
- Rest all leave to defaults
#### Task-1: Terraform Tool Installer   
- **Display Name:** Install Terraform latest version
- **Version:** 1.0.5 (as on today)
- **Important Note:** Get latest terraform version number from [Terraform Downloads page](https://www.terraform.io/downloads.html)

#### Task-2: Terraform: init
- **Display Name:** Terraform: init
- **Provider:** azurerm
- **Command:** init
- **Configuration directory:** Select by browsing it (Example: $(System.DefaultWorkingDirectory)/_Terraform Continuous Integration CI Pipeline/terraform-manifests)
- **Additional command arguments:** Nothing leave empty
- **AzureRM backend configuration**
- **Azure subscription:** terraformiacdevops1 (Select the service connection created in step-10)
- **Resource group:** terraform-storage-rg
- **Storage account:** terraformstate201
- **Container:** tfstatefiles
- **Key:** dev-terraform.tfstate
- Rest all leave to defaults

#### Task-3: Terraform: validate
- **Display Name:** Terraform: validate
- **Provider:** azurerm
- **Command:** validate
- **Configuration directory:** Select by browsing it (Example: $(System.DefaultWorkingDirectory)/_Terraform Continuous Integration CI Pipeline/terraform-manifests)
- **Additional command arguments:** Nothing leave empty
- Rest all leave to defaults

#### Task-4: Terraform: plan
- **Display Name:** Terraform: plan
- **Provider:** azurerm
- **Command:** plan
- **Configuration directory:** Select by browsing it (Example: $(System.DefaultWorkingDirectory)/_Terraform Continuous Integration CI Pipeline/terraform-manifests)
- **Additional command arguments:** -var-file=dev.tfvars
- **Azure subscription:** terraformiacdevops1 (Select the service connection created in step-10)
- Rest all leave to defaults

#### Task-5: Terraform: apply -auto-approve
- **Display Name:** Terraform: apply -auto-approve
- **Provider:** azurerm
- **Command:** validate and apply
- **Configuration directory:** Select by browsing it (Example: $(System.DefaultWorkingDirectory)/_Terraform Continuous Integration CI Pipeline/terraform-manifests)
- **Additional command arguments:** -var-file=dev.tfvars -auto-approve
- **Azure subscription:** terraformiacdevops1 (Select the service connection created in step-10)
- Rest all leave to defaults

- Click on **Save* to save the release-pipeline. 


## Step-12: Release Pipeline - Artifacts Settings
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Releases -> Terraform-CD
### Step-12-01: Add Artifacts
- Click on **Add Artifacts**
- **Source Type:** Build
- **Project:** 
- **Source (build pipeline):** Terraform Continuous Integration CI Pipeline
- **Default version:** Latest (leave to default)
- **Source alias:** _Terraform Continuous Integration CI Pipeline (leave to default)
- Click on **Add**

### Step-12-02: Enable Continuous deployment trigger
- **Continuous deployment trigger:** Enabled
- Rest all leave to defaults

## Step-13: Trigger Build (CI) and Release (CD) Pipelines
- Make a minor change in git repo and push the changes from local git repo
```t
## In any file add some changes
Example: Add some comment in any of the *.tf files (Just for testing)

# Git Status
git status

# Git Commit
git commit -am "CICD-Test-1"

# Git Push
git push
```

## Step-14: Review Build (CI) Pipeline  and Release Pipeline(CD) Logs
### Verify Build Pipeline Logs
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Pipelines -> Terraform Continuous Integration CI Pipeline

### Verify Release Pipeline Logs
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Releases -> Terraform CD


## Step-15: Verify Dev Resources created in Azure Portal
### Verify dev-terraform.tfsate file
- Go to Storaage Accounts -> terraform-rg-storage -> terraformstate -> tfstatefiles
- Verify the file `dev-terraform.tfstate`
### Verify Dev Resources in Azure Portal
1. Azure Virtual Network
2. Azure Subnets
3. Azure Public IP
4. Azure Linux Virtual Machine

## Step-16: Create Stages listed below by cloning Dev Stage in Releases
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Releases -> Terraform CD -> Edit
- Updates include the following for QA, Stage and Prod
### Task-1: Terraform: init
- Update `Key` to respective environment
- **QA Key:** qa-terraform.tfsate
- **Stage Key:** stage-terraform.tfstate
- **Prod Key:** prod-terraform.tfstate
### Task-2: Terraform: plan
- Update `Additional command arguments` to respective environment
- **QA Additional command arguments:** -var-file=qa.tfvars
- **Stage Additional command arguments:** -var-file=stage.tfvars
- **Prod Additional command arguments:** -var-file=prod.tfvars
### Task-3: Terraform: apply -auto-approve
- Update `Additional command arguments` to respective environment
- **QA Additional command arguments:** -var-file=qa.tfvars -auto-approve
- **Stage Additional command arguments:** -var-file=stage.tfvars -auto-approve
- **Prod Additional command arguments:** -var-file=prod.tfvars -auto-approve

## Step-17: Add Pre-Deployment Approval and Post Deployment Approvals
- **Pre-Deployment Approvals:** QA, Stage and Prod
- **Post-Deployment Approvals:** Stage

## Step-19: Trigger Build (CI) and Release (CD) Pipelines
- Make a minor change in git repo and push the changes from local git repo
```t
## In any file add some changes
Example: Add some comment in any of the *.tf files (Just for testing)

# Git Status
git status

# Git Commit
git commit -am "CICD-Test-2"

# Git Push
git push
```


## Step-20: Verify Resources created in Azure Portal for QA, Stage and Prod Environments
### Verify TFState File for Dev, QA and Prod
- Go to Storaage Accounts -> terraform-rg-storage -> terraformstate -> tfstatefiles
- Verify the files listed below
- qa-terraform.tfstate
- stage-terraform.tfstate
- prod-terraform.tfstate
### Verify Resources in Azure Portal for QA, Stage and Prod Environments
1. Azure Virtual Network
2. Azure Subnets
3. Azure Public IP
4. Azure Linux Virtual Machine



## Step-21: Review Build (CI) Pipeline  and Release Pipeline(CD) Logs
### Verify Build Pipeline Logs
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Pipelines -> Terraform Continuous Integration CI Pipeline

### Verify Release Pipeline Logs
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Releases -> Terraform CD
- **Dev Stage:** Review Logs
- **QA Stage:** Approve (Pre-Deployment Approval) and Review Logs
- **Staging Stage:** Approve (Pre-Deployment Approval) and Review logs and also do Post-Deployment Approval
- **Prod Stage:** Approve (Pre-Deployment Approval) 

### Verify Virtual Machines in Azure Portal
- Go to -> Virtual Machines
- Verify VM `hr-prod-web-linuxvm` and get the Public IP
```t
# Connect to prod VM using SSH
ssh -i ssh-keys/terraform-azure.pem produser@<Prod-VM-Public-IP>
```

## Step-22: Disable Build (CI) Pipeline
- Go to  Azure DevOps -> Organization  -> Project  -> Pipelines -> Pipelines -> Terraform Continuous Integration CI Pipeline
- Settings -> Disabled -> Click on **Save**
- This will help us if by any chance you made any accidental commits to your git repo we don't get any unexpected surprise azure bills. 

## Step-23: Delete Resources or Clean-Up
### Delete Resources
- Go to Azure Portal -> Resource Groups -> Delete Resource Groups for All Environments
- Dev
- QA
- Staging
- Prod
### Delete Terraform State Files
- Go to Azure Portal -> Storage Containers -> terraformstate -> Containers -> tfstatefiles -> Delete all files
- dev-terraform.tfstate
- qa-terraform.tfstate
- stage-terraform.tfstate
- prod-terraform.tfstate

