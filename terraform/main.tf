
resource "aws_security_group" "webapp_db_sg" {
  
  name= "webapp-secgroup"

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

resource "aws_instance" "webapp" {
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

  resource "aws_db_instance" "myrdsdb" {
    engine = "mysql"
    engine_version = "8.0.33"
    allocated_storage = 200
    instance_class = "db.m5.large"
    storage_type = "gp3"
    identifier = "student"
    username = var.DB_USERNAME
    password = var.DB_PASSWORD
    publicly_accessible = true
    skip_final_snapshot = true

    tags = {
      name="Myrdsdb"
    }

     vpc_security_group_ids = [aws_security_group.webapp_db_sg.id]

  }

  resource "aws_lb" "webapp_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.webapp_db_sg.id]
  subnets            = ["subnet-0c0f46c3eca6b2961", "subnet-09d4cac8fc11e1963", "subnet-0e86bdacd91046454"]

  enable_deletion_protection = false

  enable_http2 = true

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "WebApp-LB"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0ebfaf10c97954cfb"

  health_check {
    path = "/"
  }
}

resource "aws_autoscaling_group" "webapp_asg" {
  name                 = "webapp-asg"
  launch_configuration = aws_launch_configuration.webapp_lc.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier = ["subnet-0c0f46c3eca6b2961", "subnet-09d4cac8fc11e1963", "subnet-0e86bdacd91046454"]

  target_group_arns = [aws_lb_target_group.webapp_tg.arn]

  tag {
    key                 = "Name"
    value               = "webapp-instance"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "webapp_lc" {
  name_prefix   = "webapp-lc"
  image_id      = "ami-05548f9cecf47b442"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webapp_db_sg.id]
  key_name      = "vedad-varupa-web-server-key"

  user_data = <<-EOT
 #!/bin/bash
   sudo yum install epel-release -y
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "webapp_scale_in_schedule" {
  scheduled_action_name  = "scale-in"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 0 * * *"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_autoscaling_schedule" "webapp_scale_out_schedule" {
  scheduled_action_name  = "scale-out"
  min_size               = 4
  max_size               = 4
  desired_capacity       = 4
  recurrence             = "0 12 * * *"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_lb_listener" "alb_forward_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port ="80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}
