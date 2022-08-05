provider "aws" {
 region = "us-east-1"
 access_key = "XXXXXXXX"
 secret_key = "YYYYYYYYYY"
}
 
resource "aws_vpc" "test-prodVPC" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
 tags = {
    Name = "test-podVPC"
	Owner = "Balaram"
	environment = "Dev"
	project = "My project"
    }
}

resource "aws_internet_gateway" "test-prodIGW" {
  tags = {
        Name = "test-prodigw"
        Owner = "Balaram"
	Environment = "Dev"
	Project = "My project"
    }
}

resource "aws_internet_gateway_attachment" "test-prodIGW" {
  internet_gateway_id = aws_internet_gateway.test-prodIGW.id
  vpc_id              = aws_vpc.test-prodVPC.id
}

resource "aws_subnet" "test-prod-pub1" {
    vpc_id = aws_vpc.test-prodVPC.id
    cidr_block = "10.2.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
 tags = {
        Name = "test-prod-subnet-pub1"
	Owner = "Balaram"
	Environment = "Dev"
	Project = "My project"
    }
}


resource "aws_subnet" "test-prod-priv1" {
    vpc_id = aws_vpc.test-prodVPC.id
    cidr_block = "10.2.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  tags = {
        Name = "test-prodsubnet-priv1"
	Owner = "Balaram"
	Environment = "Dev"
	Project = "My project"
    }
	
}

resource "aws_route_table" "test-prodRT-pub" {
    vpc_id = aws_vpc.test-prodVPC.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test-prodIGW.id
    }
  tags = {
        Name = "test-prodRT-pub"
	Owner = "Balaram"
	Environment = "Dev"
	Project = "My project"
    }
}

resource "aws_route_table_association" "test-prodRT" {
    subnet_id = aws_subnet.test-prod-pub1.id
    route_table_id = aws_route_table.test-prodRT-pub.id
}

resource "aws_route_table" "test-prodRT-priv" {
    vpc_id = aws_vpc.test-prodVPC.id
 tags = {
        Name = "test-prodRT-priv"
        Owner = "Balaram"
        Environment = "Dev"
        Project = "My project"
    }
}

resource "aws_route_table_association" "test-prodRT-priv1" {
    subnet_id = aws_subnet.test-prod-priv1.id
    route_table_id = aws_route_table.test-prodRT-priv.id
}

resource "aws_security_group" "test-prod-SG" {
  description = "aws_vpc.Allow all inbound traffic"
  vpc_id      =  aws_vpc.test-prodVPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "Webserver1" {
      ami = "ami-0cff7528ff583bf9a"
	  availability_zone = "us-east-1a"
	  instance_type = "t2.micro"
	  vpc_security_group_ids = ["${aws_security_group.test-prod-SG.id}"]
	  key_name = "RamAWS"
	  subnet_id = aws_subnet.test-prod-pub1.id
	  associate_public_ip_address = true
          user_data = "${file("nginx.txt")}"
      tags = {
	        Name = "Webserver1"
	        Owner = "Balaram"
	        Environment = "Dev"
	        Project = "My project"
		}
	}
