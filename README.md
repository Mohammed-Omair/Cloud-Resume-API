# 🚀 Cloud Resume API with Terraform & GitHub Actions  

This repository contains an **automated serverless API** built using **AWS Lambda, DynamoDB, API Gateway, Terraform, and GitHub Actions**. The API serves structured **resume data** stored in DynamoDB and is deployed automatically whenever the Lambda code or `resume.json` changes.

---

## 🌟 Features  
- **Serverless Architecture** → AWS Lambda + API Gateway  
- **Infrastructure as Code (IaC)** → Managed with Terraform  
- **CI/CD Automation** → GitHub Actions for deployments  
- **Auto Updates** → API redeploys on every change to `lambda_function.py` or `resume.json`  
- **Secure & Scalable** → Uses S3-backed Terraform state for consistency  

---

## 🏗️ Architecture  

![Architecture Diagram](https://github.com/user-attachments/assets/b56b194c-155e-442a-80b0-63a4f7337abb)


- **AWS Lambda** → Fetches resume data from **DynamoDB**  
- **DynamoDB** → Stores structured **resume.json** data  
- **API Gateway** → Exposes Lambda as a public API  
- **Terraform** → Deploys & manages AWS infrastructure  
- **GitHub Actions** → Automates Terraform deployments  

---

## 🛠️ Prerequisites  

- **AWS Account** with IAM permissions for:
  - DynamoDB, Lambda, API Gateway, S3  
- **Terraform Installed** (`>=1.0.0`)  
- **AWS CLI Installed** (`aws configure` set up)  

---
The full step-by-step guide can be found [here](https://www.linkedin.com/pulse/cloud-resume-api-deployment-terraform-github-actions-mohiuddin-pen3c/?trackingId=FfEnE5dySGSUepcMSfyV0Q%3D%3D)
API URL: [https://hnrkedwr7c.execute-api.us-east-2.amazonaws.com/default/](https://hnrkedwr7c.execute-api.us-east-2.amazonaws.com/default/)

