# Terraform AWS VPC + EC2 + Apache Setup

This project provisions an AWS infrastructure using **Terraform**. It sets up a custom VPC, subnet, route table, internet gateway, security group, Elastic IP, and an EC2 Ubuntu 22.04 instance with **Apache web server** installed automatically via `user_data`.

---

## 🚀 Features
- Custom VPC with CIDR `10.0.0.0/16`
- Public Subnet with CIDR `10.0.1.0/24`
- Internet Gateway & Route Table association
- Security Group allowing **SSH (22), HTTP (80), HTTPS (443)**
- Elastic IP attached to ENI
- Ubuntu 22.04 EC2 instance (t3.micro by default)
- Apache installed & started automatically

---

## 📂 Files
- `main.tf` → Terraform code (VPC, Subnet, EC2, Security Groups, Apache setup)
- `variables.tf` → Input variables
- `outputs.tf` → (Optional) To print useful info like Public IP after deployment

---

## 🔧 Prerequisites
1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.1.0)
2. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and configure credentials:
   ```bash
   aws configure
   ```
3. Ensure you have an **existing AWS Key Pair** (`.pem` file) for SSH access.
   - Update the variable `key_name` in `variables.tf` with your Key Pair name.
   - Keep your `.pem` file safe in `~/.ssh/`.

---

## ▶️ Usage

### 1. Clone the Repository
```bash
git clone https://github.com/imrankhanmohammad257/terraform-aws-ubuntu.git
cd terraform-aws-apache
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Validate the Configuration
```bash
terraform validate
```

### 4. Plan the Infrastructure
```bash
terraform plan
```

### 5. Apply the Configuration
```bash
terraform apply -auto-approve
```

---

## 🌍 Accessing the Apache Web Server
1. Get the **Public IP** of the EC2 instance:
   ```bash
   terraform output
   ```
   Or check in AWS Console.

2. Open in browser:
   ```
   http://<PUBLIC_IP>
   ```

You should see the default **Apache2 Ubuntu Default Page** 🎉

---

## 🔑 SSH Access (Optional)
If you provided a valid Key Pair:

```bash
ssh -i ~/.ssh/mumbai.pem ubuntu@<PUBLIC_IP>
```

---

## 🧹 Clean Up
To destroy all resources:
```bash
terraform destroy -auto-approve
```

---

## 📌 Notes
- Default region is **ap-south-1 (Mumbai)**. Change in `variables.tf` if needed.
- The EC2 instance runs **Ubuntu 22.04 LTS (Jammy Jellyfish)**.
- Apache is installed automatically via `user_data`.
- Make sure your **AWS credentials** have permission to create VPC, EC2, and networking components.

---
✅ Infrastructure is fully automated with Terraform.
