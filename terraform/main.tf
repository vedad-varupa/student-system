
resource "aws_security_group" "webapp_db_sg" {
  name= "webapp-sg"

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webapp_and_db" {
  ami           = "ami-05548f9cecf47b442" 
  instance_type = "t2.micro"     
  subnet_id     = "subnet-0c0f46c3eca6b2961"  
  key_name      = "vedad-varupa-web-server-key"
  tags = {
    Name = "Webapp"
  }
user_data = <<-EOT
 #!/bin/bash
   sudo yum install epel-release -y
   sudo yum install nginx -y
   sudo systemctl start nginx
   sudo systemctl enable nginx
   sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
   sudo yum install -y http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
   sudo yum install -y mysql-community-server
   sudo systemctl enable mysqld
   sudo service mysqld start
   sudo yum install java-17-amazon-correto-devel
   sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
   sudo sed -i s/\$releasever/7/g /etc/yum.repos.d/epel-apache-maven.repo
   sudo yum install -y apache-maven
   curl -L -o nodesource_setup.sh https://rpm.nodesource.com/setup_18.x
   sudo bash nodesource_setup.sh
   sudo yum install nodejs -y
   sudo yum install -y gcc-c++ make
   sudo npm install -g pm2
    EOT
  
  vpc_security_group_ids = [aws_security_group.webapp_db_sg.id]
  }

