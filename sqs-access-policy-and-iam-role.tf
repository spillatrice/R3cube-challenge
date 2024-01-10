#Create the IAM policy for SQS Send/Receive
resource "aws_iam_policy" "sqs_access_policy" {
    name        = "SQSAccessPolicy"
    description = "IAM policy for SQS access"
  
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
          ],
          Resource = "arn:aws:sqs:eu-west-1:054369683753:R3CUBE-Queue"
        }
      ]
    })
  }

#Create the IAM Role for SQS
  resource "aws_iam_role" "sqs_role" {
  name = "SQSRole"

    assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach the SQS access policy to the created IAM role
resource "aws_iam_policy_attachment" "sqs_access_attachment" {
  name       = "sqs-access-attachment"
  policy_arn = aws_iam_policy.sqs_access_policy.arn  # Reference the IAM policy resource
  roles      = [aws_iam_role.sqs_role.name]
}

  