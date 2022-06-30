# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  #access_key = "AKIAUEU726P5QHVOSIZ4"
  #secret_key = "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"
}

#aws vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
#public subnet
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true


}
#internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}


#keypair

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjowbl8mM1ObzhCKPAMK6IBOPmv42ijj0CiNGLNsiNDaq/BgMOrO2ILSxw0xlc8LQNDMUWkV8fWxj60NQ0MuNIlXVeakNAPo1DzxVbmzpm80e5s6KCwrBYP1+VSreej9DR7wS6bvL8eNr1w/XFMl9j8vx3ZUSnqW80o2f/822RvegTY3y93oPL5G3vJYeeC36JAZEnaqC+MqCHhRLPN1m1ZUXGfL/UwexO6L90kv6hh9ruMKyDXgDAxpClf9C5kbBHeU08Yt5KEtQCyXb0s2n/mxjCpKjiuhfEVJKTJLgPE9iOIZrXCKrzirri9HzrlsC0qyh7MLbyHc8jTVmttyXXGANFBYcAXCjd+j2cWnchXo49+wSU4iEbYKS/CHZdxJZt3/3HF9k0LUQQ0HXC4yxNrAqdkWHB4caP9Fcox0CNen2+IjCnYu53EW0g6gmmdNVKxOpJTiagGn7NVWhqEou/NXjoJW5JGqHjJGR/2bP+cFgrWHqi5P+jn7wOaQ01e7k= root@server1.crazytechgeek.info"
}
#route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

}



#gecurity-group

resource "aws_security_group" "sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
}




#ec2

resource "aws_instance" "web" {
  ami           = "ami-02f3416038bdb17fb"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.sg.id]

}
#IAM

resource "aws_iam_user" "iam" {
  name = "test"
  path = "/"


}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.iam.id
}

resource "aws_iam_user_policy" "lb_ro" {
  
  user = aws_iam_user.iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



#s3

resource "aws_s3_bucket" "s3" {
  bucket = "usecase-bk"
}
















