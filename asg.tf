#Get Linux AMI using SSM Parameter endpoint in us-east-2
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_launch_configuration" "asg-launch-config-sample" {
  provider                    = aws.region-master
  associate_public_ip_address = true
  image_id                    = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web-sg.id]
  key_name                    = "gitlab.pem"
  user_data                   = <<EOF
                                #! /bin/bash
                                sudo yum install httpd -y
                                echo "This is Matt's terraform auto scaling group" > /var/www/html/index.html
                                sudo yum update -y
                                sudo service httpd start
                                EOF


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg-sample" {
  provider             = aws.region-master
  launch_configuration = aws_launch_configuration.asg-launch-config-sample.id
  min_size             = 2
  max_size             = 5
  target_group_arns    = [aws_lb_target_group.lb-tg.arn]
  health_check_type    = "EC2"
  vpc_zone_identifier  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tag {
    key                 = "Name"
    value               = "matts-terraform-asg"
    propagate_at_launch = true
  }
}

