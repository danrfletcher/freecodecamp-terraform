variable "subnet_prefix" {
    description = "cidr block for the subnet"
    #default = #the default value if none is passed
    #type = #ensures user passes correct data type (can also be any)
}

variable object_variable_example {
    description = "example variable with object data type"
    #reference using var.object_variable_example[index].property
}

variable "aws_access_key" {
    description = "aws provider access_key (secret gitignored variable)"
}

variable "aws_secret_key" {
    description = "aws provider secret_key (secret gitignored variable)"
}

provider "aws" {
    region = "eu-north-1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

#1. Create VPC

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
}

#2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id
}

#3. Create Custom Route Table - see GPT3.5 thread for further info

resource "aws_route_table" "prod-route-table" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0" #default route - all traffic
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0" #ipv6 default route
        gateway_id = aws_internet_gateway.gw.id
    }
}

#4. Create a Subnet

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.subnet_prefix[0] #references first object in the list
    availability_zone = "eu-north-1a"

    tags = {
        Name = "prod-subnet"
    }
}

#5. Associate subnet with Route Table

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id
}

#6. Create Security Group to allow port 22,80,443

resource "aws_security_group" "allow_web" {
    name        = "allow_web_traffic"
    description = "Allow web traffic"
    vpc_id      = aws_vpc.prod-vpc.id

    tags = {
        Name = "allow_web"
    }

    ingress { 
        description = "HTTPS"
        from_port = 443 #here we can specify a range of ports
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #can even put any ip address in here, e.g. our own but we specify any IP here
    }

    ingress { 
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress { 
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }   
}

#7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "web-server-nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["10.0.1.50"]
    security_groups = [aws_security_group.allow_web.id]
}

#8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
    network_interface = aws_network_interface.web-server-nic.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [ aws_internet_gateway.gw ] #use this when docs specify terraform cannot depermine the dependency
}

output "server_public_ip" {
    value = aws_eip.one.public_ip #prints this value to console on terraform apply or teraform refresh
}

#9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "web-server-instance" {
    ami = "ami-0914547665e6a707c"
    instance_type = "t3.micro"
    availability_zone = "eu-north-1a"
    key_name = "scottyfairno-sandbox-newkey"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first Terraform web server is working! > /var/www/html/index.html'
                EOF
    
    tags = {
      Name = "web-server"
    }
}