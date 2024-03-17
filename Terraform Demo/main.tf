provider "aws" {
    region = "us-east-1"
    #access_key = 
    #secret_key = 
}

/* --- Structure of resource creation syntax --- */
# resource "<provider e.g. aws>_<resource type>" "name" {
#   config options...connection {
#     key = "value"
#     key2 = "value2"
#   }
# }

/* --- Deploying an EC2 instance in AWS with Terraform --- */
# You can destroy this instance after deploymet, simply by commenting out the code below
resource "aws_instance" "test-ec2-instance" {
    ami = "ami-0d7a109bf30624c99"
    instance_type = "t2.micro"

    tags = {
      Name = "AmazonLinuxServer"
    }
}

resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16" #See docs for info on this
    tags = {
      Name = "FirstTerraformVPC"
    }
}

resource "aws_subnet" "first-subnet" {
  vpc_id = aws_vpc.first-vpc.id #We can reference the VPC that is being created above in this way to get its ID
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "FirstTerraformSubnet"
  }
}
