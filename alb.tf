resource "aws_lb" "matts_lb" {
  provider           = aws.region-master
  name               = "matts-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {

    Name = "Matts-Application-tf"
  }
}


resource "aws_lb_target_group" "lb-tg" {
  provider = aws.region-master
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_master.id
  health_check {
    interval            = 70
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

# Create ALB Listener

resource "aws_lb_listener" "lb-listner" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.matts_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}
