resource "aws_launch_configuration" "example_launch_config" {
  name = "TestDev"
  image_id            = "ami-062a49a8152e4c031"  # Replace with your desired AMI ID
  instance_type        = "t2.micro"  # Replace with your desired instance type
  key_name      = "testkeypair"
  associate_public_ip_address = true
  # Add other configuration options like key_name, security_groups, etc. as needed
}

resource "aws_autoscaling_group" "example_autoscaling_group" {
  name                 = "YourAutoScalingGroup"
  launch_configuration = aws_launch_configuration.example_launch_config.id
  min_size             = 0
  max_size             = 4
  desired_capacity     = 2 # Initial desired capacity
  # Add at least one subnet identifier where instances will be launched
  vpc_zone_identifier  = ["subnet-0cd6a3a91bb2e36e6", "subnet-03eeafdaddf0d2f50"]  # Replace with your subnet IDs
}


