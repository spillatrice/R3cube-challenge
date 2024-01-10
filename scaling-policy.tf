#Create the Scale Down Metric Alarm in CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "SQSMessageCountScaleDown"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 2  # Set your threshold value for scaling down
  alarm_description   = "Alarm for scaling down"
  actions_enabled     = true
  alarm_actions       = [resource.aws_autoscaling_policy.scale_down_policy.arn] 

  dimensions = {
    QueueName = "R3CUBE-Queue"
  }
}

#Create the Scale Up Metric Alarm in CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "SQSMessageCountScaleUp"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 5  # Set your threshold value for scaling up
  alarm_description   = "Alarm for scaling up"
  actions_enabled     = true
  alarm_actions       = [resource.aws_autoscaling_policy.scale_up_policy.arn]

  dimensions = {
    QueueName = "R3CUBE-Queue"
  }
}

#Create the AutoScaling Up Policy. When 5 or more SQS messages are visible, after 1 minute creates 1 EC2 Instance
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "ScaleUpPolicy"
  scaling_adjustment    = 1 # Increase instance count by 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = "YourAutoScalingGroup"
}

output "autoscaling_policy_arn" {
  value = resource.aws_autoscaling_policy.scale_up_policy.arn
}

#Create the AutoScaling Up Policy. When 2 or less SQS messages are visible, after 1 minute deletes 4 instances
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "ScaleDownPolicy"
  scaling_adjustment      = -4  # Decrease instance count by 4
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "YourAutoScalingGroup"
}

output "autoscaling_policy2_arn" {
  value = resource.aws_autoscaling_policy.scale_down_policy.arn
}

#Create a CloudWatch Dashboard for EC2 Metrics - !! Beware it doesn't correctly work (meaning that it creates the dashboard but doesn't attach the correct InstanceID) !!
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "EC2-Metrics-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_launch_configuration.example_launch_config.id
            ]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-1"
          title  = "EC2 Instance CPU"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
}
