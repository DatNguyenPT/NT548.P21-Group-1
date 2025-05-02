# Hướng dẫn triển khai hạ tầng AWS với CloudFormation

## Tổng quan

Giải pháp này sử dụng CloudFormation Nested Stacks để triển khai một hạ tầng AWS theo cấu trúc module, bao gồm:

1. **VPC module**: Tạo VPC, public subnet, private subnet và default security group
2. **Network module**: Tạo Internet Gateway, NAT Gateway và các Route Tables
3. **Security module**: Tạo các Security Group cho EC2 instances 
4. **Compute module**: Tạo EC2 instances trong public và private subnet
5. **Root stack**: Kết hợp tất cả các module lại với nhau

## Cấu trúc hạ tầng

- **VPC** với CIDR 10.0.0.0/16
- Một **Public Subnet** (10.0.0.0/24) và một **Private Subnet** (10.0.1.0/24)
- **Internet Gateway** kết nối với Public Subnet
- **NAT Gateway** trong Public Subnet cho phép Private Subnet kết nối ra Internet
- **Route Tables** cho Public và Private Subnet
- **EC2 instance** trong Public Subnet (public-ec2) và Private Subnet (private-ec2)
- **Security Groups**:
  - public-secgroup: Cho phép SSH từ IP được chỉ định
  - private-secgroup: Cho phép SSH từ public-ec2

## Các bước triển khai

### 1. Tạo S3 bucket để lưu trữ template

```bash

aws s3 mb s3://lab1-nested-stack-1234-ap-southeast-2

```

### 2. Upload các template vào S3 bucket

```bash
aws s3 cp vpc-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp network-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp security-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp compute-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp root-stack.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
```

### 3. Triển khai root stack

```bash
aws cloudformation create-stack \
  --stack-name aws-infrastructure \
  --template-url https://lab1-nested-stack-1234-ap-southeast-2.s3.amazonaws.com/root-stack.yaml \
  --parameters ParameterKey=AllowedIP,ParameterValue=your-ip/32 \
               ParameterKey=KeyName,ParameterValue=your-key-pair \
               ParameterKey=S3BucketName, ParameterValue=s3-bucket-name \
  --capabilities CAPABILITY_IAM
```
Thay `your-ip/32` bằng địa chỉ IP của bạn (ví dụ: 203.0.113.10/32) và `your-key-pair` bằng tên của EC2 KeyPair có sẵn, `s3-bucket-name` bằng tên s3 bucket vừa tạo.

### 4. Theo dõi quá trình triển khai

```bash
aws cloudformation describe-stacks --stack-name aws-infrastructure
```

## Kết nối đến EC2 instances

### Kết nối đến public EC2

```bash
ssh -i your-key-pair.pem ec2-user@<public-ec2-public-ip>
```

Địa chỉ IP công khai của public EC2 có thể được lấy từ output của stack.

### Kết nối đến private EC2 (thông qua public EC2)

1. Trước tiên, copy private key đến public EC2:

```bash
scp -i your-key-pair.pem your-key-pair.pem ec2-user@<public-ec2-public-ip>:/home/ec2-user/
```

2. Kết nối đến public EC2:

```bash
ssh -i your-key-pair.pem ec2-user@<public-ec2-public-ip>
```

3. Từ public EC2, kết nối đến private EC2:

```bash
ssh -i your-key-pair.pem ec2-user@<private-ec2-private-ip>
```

## Xóa stack

Khi bạn không còn cần hạ tầng này, có thể xóa bằng lệnh:

```bash
aws cloudformation delete-stack --stack-name aws-infrastructure
```

Lưu ý: CloudFormation sẽ tự động xóa tất cả các nested stack.