provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    
    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

resource "aws_security_group" "automation_sg" {
    name="tf-ec2-sg"
    description="Allow SSH and HTTP"
    
    ingress{
        description= "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress{
        description= "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress{
        from_port = 0
        to_port =0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "automation_web" {
    ami= data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    key_name = "automation"
    vpc_security_group_ids = [aws_security_group.automation_sg.id]
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd curl
        systemctl start httpd
        systemctl enable httpd
        cd /var/www/html
        curl -o index.html https://raw.githubusercontent.com/XnoahR/automation/main/challenge.html
        EOF

    tags = {
        Name = "tf-ec2-web"
    }
}

# Output IP/DNS setelah deploy
output "ec2_public_ip" {
  value = aws_instance.automation_web.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.automation_web.public_dns
}
