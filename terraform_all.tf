#Define aws Provider
provider "aws" {
	region = "ap-south-1"	#aws region where resource will be created
}

#VPC
resource "aws_vpc" "main1" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = true
	enable_dns_hostnames = true

	tags = {
		Name = "MyVPC1"
	}
}

#Subnet
resource "aws_subnet" "public_subnet1" {
	vpc_id = aws_vpc.main1.id
	cidr_block = "10.0.0.0/24"
    	map_public_ip_on_launch = true
	availability_zone = "ap-south-1a"
	
	tags = {
		Name = "PublicSubnet1"
	}
}

#Internet Gateway
resource "aws_internet_gateway" "igw1" {
	vpc_id = aws_vpc.main1.id

	tags = {
		Name = "MyIGW1"
	}
}

#Route Table
resource "aws_route_table" "public_rt1" {
	vpc_id = aws_vpc.main1.id

	tags = {
		Name = "PublicRouteTable1"
	}
}

resource "aws_route" "internet_access" {
	route_table_id = aws_route_table.public_rt1.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.igw1.id
}

resource "aws_route_table_association" "public_assoc" {
	subnet_id = aws_subnet.public_subnet1.id
	route_table_id = aws_route_table.public_rt1.id
}

resource "aws_security_group" "allow_ssh" {
	name = "allow_ssh"
	vpc_id = aws_vpc.main1.id
	
	ingress {
		description = "SSH access"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description = "Allow all traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

}

#create EC2 instance
resource "aws_instance" "my_server" {
	
	# creates 3 EC2 instances
	#count = 3

	#AMI ID = operating system image
	ami = "ami-0f559c3642608c138"

	#Instance Size (free tier eligible)
	instance_type = "t3.micro"

	#Your key name
	key_name = "WebServer"
	
	#Subnet Id
	subnet_id = aws_subnet.public_subnet1.id

	#Security Group
	vpc_security_group_ids = [aws_security_group.allow_ssh.id]
	
	
	tags = {
		Name = "Terraform-EC2"
	}
}

