provider "aws" {
    region = "us-east-2"
}

# API

resource "aws_api_gateway_rest_api" "HelloWorldApi" {
  name        = "HelloWorldApi"
  description = "HelloWorld API GET request to heroku"
}

resource "aws_api_gateway_resource" "ApiResource" {
  rest_api_id = aws_api_gateway_rest_api.HelloWorldApi.id
  parent_id   = aws_api_gateway_rest_api.HelloWorldApi.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "ApiMethod" {
  rest_api_id   = aws_api_gateway_rest_api.HelloWorldApi.id
  resource_id   = aws_api_gateway_resource.ApiResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ApiIntegration" {
  rest_api_id = aws_api_gateway_rest_api.HelloWorldApi.id
  resource_id = aws_api_gateway_resource.ApiResource.id
  http_method = aws_api_gateway_method.ApiMethod.http_method
  integration_http_method = "GET"
  type = "HTTP_PROXY"
  uri = "https://painteger.herokuapp.com/hello"
}

resource "aws_api_gateway_deployment" "ApiDeployment" {
  depends_on = [aws_api_gateway_integration.ApiIntegration]

  rest_api_id = aws_api_gateway_rest_api.HelloWorldApi.id
  stage_name  = "dev"

  lifecycle {
    create_before_destroy = true
  }
}


output "gateway_link" {
  value = "${aws_api_gateway_deployment.ApiDeployment.invoke_url}/${aws_api_gateway_resource.ApiResource.path_part}"
  description = "HelloWorld API request URL"
}

# DATABASE

resource "aws_db_instance" "mysqldb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "testdb"
  username             = "admin"
  password             = "adminpass"
}

output "mysqldb_endpoint" {
  value = aws_db_instance.mysqldb.endpoint
  description = "MySql Database instance endpoint"
}


# WEB APPLICATION

resource "aws_launch_configuration" "example_ec2" {
  image_id = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" & 
                EOF

  security_groups = [aws_security_group.asg_ec2_example.id]

    lifecycle {
      create_before_destroy = true
  }
}


resource "aws_security_group" "asg_ec2_example" {
    name = "asg_ec2_example"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "HTTP requests port"
    type = number
    default = 8080
}

resource "aws_autoscaling_group" "autoscaling_example" {
    launch_configuration = aws_launch_configuration.example_ec2.id

    min_size = 2
    max_size = 10

    load_balancers = [aws_elb.elb_example.name]
    health_check_type = "ELB"
    availability_zones = data.aws_availability_zones.all.names

    tag {
        key = "Name"
        value = "autoscaling_example"
        propagate_at_launch = true
    }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "elb_example" {
    name = "elbexample"
    availability_zones = data.aws_availability_zones.all.names
    security_groups = [aws_security_group.elb.id]

    health_check{
        target = "HTTP:${var.server_port}/"
        interval = 30
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = var.server_port
        instance_protocol = "http"
    }
}

resource "aws_security_group" "elb" {
    name = "terraform-elb"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

output "dns_name" {
    value = aws_elb.elb_example.dns_name
    description = "DNS name"
}