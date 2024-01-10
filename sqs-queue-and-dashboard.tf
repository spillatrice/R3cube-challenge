# Create SQS Queue
resource "aws_sqs_queue" "example_queue" {
  name                      = "R3CUBE-Queue"  # Replace with your desired queue name
  delay_seconds             = 0 #Delay of the message sent, in secs
  max_message_size          = 2048 
  message_retention_seconds = 600
  visibility_timeout_seconds = 600
  }

# Define SQS Queue Policy
resource "aws_sqs_queue_policy" "example_queue_policy" {
  queue_url = aws_sqs_queue.example_queue.id  # Reference to the created queue

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = aws_sqs_queue.example_queue.arn,  # Reference to the ARN of the created queue
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sqs_queue.example_queue.arn
        }
      }
    }]
  })
}

#Create CloudWatch Dashboard for SQS Metrics
resource "aws_cloudwatch_dashboard" "sqs_dashboard" {
  dashboard_name = "SQS-Metrics-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric",
        x          = 0,
        y          = 0,
        width      = 12,
        height     = 6,
        properties = {
          metrics = [
            [
              "AWS/SQS",
              "ApproximateNumberOfMessagesVisible",
              "QueueName",
              "R3CUBE-Queue"  # Replace with your queue name
            ]
          ],
          region = "eu-west-1" # Replace with the region interested
        }
      }
    ]
  })
}