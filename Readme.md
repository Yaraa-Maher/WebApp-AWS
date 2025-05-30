# Auto-Scaling Web Application on AWS

## Overview
A secure, highly available, and auto-scaling web application using:
- EC2 instances
- Application Load Balancer (ALB)
- Auto Scaling Groups (ASG)
- (Optional) Amazon RDS
- CloudWatch and SNS for monitoring

## Features

- Load Balanced traffic using ALB
- Auto Scaling based on CPU utilization
- Web app hosted on EC2 instances across multiple Availability Zones
- Real-time Monitoring and Notifications using CloudWatch + SNS
- (Optional) RDS Multi-AZ database backend
- IAM role-based permissions for secure access

---

## Tech Stack

- **Amazon EC2**
- **Application Load Balancer (ALB)**
- **Auto Scaling Group (ASG)**
- **CloudWatch + SNS**
- **IAM Roles**
- **(Optional) Amazon RDS**
- **HTML / Apache Web Server**

---

## Architecture Diagram

![Architecture](docs/architecture-diagram.png)

---

##  Step-by-Step Deployment Guide

### 1. **VPC Setup**
- Use **default VPC** or create a new one.
- Public Subnets (2) for EC2 + Private Subnets (2) for RDS.
- Attach Internet Gateway and configure route tables.

### 2. **Security Groups**
- EC2 SG: Allow HTTP (80), HTTPS (443), SSH (22 from your IP)
- ALB SG: Allow HTTP/HTTPS from anywhere (0.0.0.0/0)
- RDS SG (optional): Allow DB ports only from EC2 SG

### 3. **IAM Role for EC2**
Attach a role with:
- `AmazonEC2ReadOnlyAccess`
- `CloudWatchAgentServerPolicy`
- `AmazonSSMManagedInstanceCore`

### 4. **Launch Template**
- AMI: Amazon Linux 2 or Ubuntu
- Instance Type: `t2.micro` or `t3.micro`
- User Data: install Apache and deploy `index.html`
- Attach IAM Role

Example `user-data`:
```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Welcome to My Scalable Web App</h1>" > /var/www/html/index.html

### 5. Create ALB
- aws elbv2 create-load-balancer --name web-alb --subnets subnet-1 subnet-2 --security-groups sg-123

### Create Target Group
- aws elbv2 create-target-group --name web-tg --protocol HTTP --port 80 --vpc-id vpc-123

### 6. Create ASG
- aws autoscaling create-auto-scaling-group \
	--auto-scaling-group-name web-asg \
 	--launch-template "LaunchTemplateName=web-template,Version=1" \
 	--min-size 2 --max-size 5 --desired-capacity 2 \
 	--vpc-zone-identifier "subnet-1,subnet-2" \

### Scale-out policy (CPU >80%)
aws autoscaling put-scaling-policy --policy-name scale-out --auto-scaling-group-name web-asg --scaling-adjustment 1 --adjustment-type ChangeInCapacity

### 7. CloudWatch Alarm
- aws cloudwatch put-metric-alarm \
 	--alarm-name high-cpu \
  	--metric-name CPUUtilization \
  	--namespace AWS/EC2 \
 	--threshold 80 \
  	--alarm-actions "arn:aws:autoscaling:..."

---

## Testing the App
- Visit ALB DNS name
```bash
	http://web-ALB-1683263015.us-east-1.elb.amazonaws.com
	

