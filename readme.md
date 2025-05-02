# LAB 1: Dùng Terraform và Cloudformation để quản lý và triển khai hạ tầng AWS

Trong bài lab này, nhóm 1 sẽ thực hiện theo yêu cầu triển khai và quản lý hạ tầng theo 2 phương pháp IaC (Infrastructure as Code) là Terraform và Cloudformation.

## Sinh viên thực hiện

| Họ tên  | MSSV |
| ------------- | ------------- |
| Nguyễn Thượng Phúc  | 22521134  |
| Lưu Quốc Cường  | 22520173  | 
| Nguyễn Phạm Tiến Đạt  | 22520217  |

## Tổng quan 

### Terraform

- Được viết theo kiểu module. Giúp tăng cường khả năng mở rộng, tái sử dụng.
- Quá trình triển khai sẽ được thực thi trên người dùng IAM thay vì root.
- Ứng dụng các practice (Không gắn Elastic IP vào EC2 instance, xây dựng state-lock để tránh tranh chấp quyền thực thi).

### Cloudformation

- Dịch vụ quản lý hạ tầng dưới dạng mã nguồn (IaC) của AWS.
- Sử dụng các template YAML hoặc JSON để tạo và quản lý tài nguyên AWS.
- Hỗ trợ tạo stack, cập nhật, thay đổi và xóa tài nguyên một cách tự động.
- Có khả năng tự phát hiện lỗi cấu hình và rollback khi triển khai thất bại.

## Cài đặt

### 1. Cài đặt AWS CLI

#### Đối với Windows:

1. **Tải về trình cài đặt AWS CLI**:
   - Truy cập trang chính thức: [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)
   - Hoặc tải trực tiếp tại:  
     [AWS CLI MSI Installer 64-bit](https://awscli.amazonaws.com/AWSCLIV2.msi)

2. **Chạy trình cài đặt**:
   - Nhấp đúp vào file `.msi` vừa tải về.
   - Làm theo hướng dẫn trên màn hình để hoàn tất quá trình cài đặt.

3. **Xác minh cài đặt**:
   - Mở **Command Prompt (CMD)** hoặc **PowerShell**, gõ lệnh:
   ```bash
   aws --version
   ```

#### Đối với Ubuntu:

```bash
sudo apt update
sudo apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 2. Clone repository:

```bash
git clone https://github.com/DatNguyenPT/NT548.P21-Group-1.git
```

### 3. Terraform

```bash
cd 'Lab1 - Terraform'
```

Thiết lập thông tin người dùng IAM (Tên profile, Access Key, Secret Key, Region):
```bash
aws configure
```

Khởi tạo Terraform:
```bash
terraform init
```

Xem trước các thay đổi:
```bash
terraform plan
```

Áp dụng thay đổi: 
```bash
terraform apply
```
hoặc
```bash
terraform apply --auto-approve # Bỏ qua phần xác định các resource nào sẽ được tạo
```

### Cấu trúc dự án

#### Terraform
```
Lab1 - Terraform/
├── main.tf                 # File chính khai báo các module
├── variables.tf            # Khai báo các biến
├── provider.tf             # Khai báo version Terraform
├── backend              # Cấu hình backend lưu trữ terraform state
├── modules/
│   ├── ec2/                # Module EC2
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/                # Module VPC
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eip/                # Module Elastic IP
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── igw/                # Module Internet Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── nat/                # Module NAT Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rtb/                # Module Route Table
│   │   ├── private
│   │   ├── public
│   │  
│   └── sg/                 # Module Security Group
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── terraform.tfstate       # File state (được tạo sau khi apply)    
```


### 4. Cloudformation

```bash
cd 'Lab1 - CloudFormation'
```
#### Cấu trúc dự án
```
Lab1 - CloudFormation/
├── compute-module.yaml
├── network-module.yaml
├── security-module.yaml
├── vpc-module.yaml
└── root-stack.yaml

```

1. Tạo S3 bucket để lưu trữ template

```bash

aws s3 mb s3://lab1-nested-stack-1234-ap-southeast-2

```

2. Upload các template vào S3 bucket

```bash
aws s3 cp vpc-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp network-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp security-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp compute-module.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
aws s3 cp root-stack.yaml s3://lab1-nested-stack-1234-ap-southeast-2/
```

3. Triển khai root stack

```bash
aws cloudformation create-stack \
  --stack-name aws-infrastructure \
  --template-url https://lab1-nested-stack-1234-ap-southeast-2.s3.amazonaws.com/root-stack.yaml \
  --parameters ParameterKey=AllowedIP,ParameterValue=your-ip/32 \
               ParameterKey=KeyName,ParameterValue=your-key-pair \
               ParameterKey=S3BucketName,ParameterValue=s3-bucket-name \
  --capabilities CAPABILITY_IAM
```
Thay `your-ip/32` bằng địa chỉ IP của bạn (ví dụ: 203.0.113.10/32), `your-key-pair` bằng tên của EC2 KeyPair có sẵn, `s3-bucket-name` bằng tên s3 bucket vừa tạo.

4. Theo dõi quá trình triển khai

```bash
aws cloudformation describe-stacks --stack-name aws-infrastructure
```

5. Xoá stack:
```bash
aws cloudformation delete-stack --stack-name aws-infrastructure
```

## Tài liệu tham khảo

- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)