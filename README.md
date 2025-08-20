# LangGraph Google Cloud Terraform Deployment

This repository is for the Terraform deployment of LangGraph on Google Cloud.

## Prerequisites

- Terraform
- gcloud


## Architecture



## Quick Start

Setup GCP Project

```bash
export PROJECT_ID=<your-project-id>
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud auth application-default login
```

Setup variables and secrets

```bash
cp terraform.tfvars.example terraform.tfvars
cp secrets.yaml.example secrets.yaml
```

Deploy

```bash
terraform init
terraform plan
terraform apply
```

When finished, you can access the LangGraph API at `https://<service-name>-<project-id>.<region>.run.app/docs` .
