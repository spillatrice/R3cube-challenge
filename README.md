## R3cube-challenge

# Introduction 

This repository serves to prove my individual take on the AWS Ops Exercise - EC2 Autoscaling and SQS for R3cube opening position. 
To be successful, my task is to complete these mandatory requirements:

1) Create a standard Amazon SQS queue
2) Define the SQS Access Policy and Configure IAM roles for SQS send/receive operations.
3) Develop a Python producer script to send JSON messages to SQS [example](#examples-of-json-messages)
4) Create a Python consumer script to process messages from SQS and log on standard output the content
5) Set up an EC2 Auto Scaling group with min of 0 instances and max of 4 instances
6) Define scaling policies based on SQS message count (no message in the queue no instances)
7) Include the consumer script in the EC2 instance bootstrap.
8) Consumer script poll messages from the SQS queue, process them, and then wait for one minute before polling for messages again

In order to achieve these 8 tasks, I've decided to use Terraform to deploy the entire Infrastructure.
There will be a few default names (e.g. YourAutoScalingGroup). This is just an example that should not be used in production as is. 

# Optional Requirements
1) Install CloudWatch agent on EC2 instances at bootstrap or prepare an AMI with agent onboard
2) Configure Cloudwatch agent to send content of messages to CloudWatch Logs
3) Create a CloudWatch dashboard to monitor SQS metrics
4) Create a CloudWatch dashboard to monitor EC2 metrics

# Bonus Requirements
1) Use CloudFormation or Terraform for infrastructure creation.
2) Use Ansible to install and configure Cloudwatch agent
3) Share Cloudwatch dashboard with us

# SQS-Queue-And-Dashboard.tf (task 1, optional task 3)
This file simply creates an SQS queue with a defined SQS policy that allows the SendMessage action. 
From line 30 it will also create a CloudWatch Dashboard, which is an optional task, to gather SQS Metrics (ApproximateNumberOfMessagesVisiible) for the created SQS Queue.

# SQS-Access-Policy-And-Iam-Role.tf (task 2)
This file firstly creates the IAM Policy for SQS to Send/Receive message, then it creates an IAM Role for SQS and attaches the SQS Access Policy to the IAM Role 

# Producer-Script.py (task 3)
The script will be used after creating the whole infrastructure with terraform. It send a message to the SQS Queue with these defined attributes:
Vehicle (VH2001)
Make (Honda)
Model (Civic)
Year (2020)
Color (Blue)
Mileage (15000)

For security, everytime the script will be launched, a message will be printed out defining whether the message was successfully sent or not.

# Consumer-script.py (task 4, 8)
The script processess the messages sent to the SQS Queue. At the beginning, it gave me a few errors, so I put a few except to deal with it. After debugging a few times, I've found out that it was gaining an error from the MessageBody, fixing it with the final if/else that can be found in line 24-28.
Lastly, the script receives the message from the SQS queue and starts processing it. After the message is processed, it will eliminate it and wait for 1 minute before polling again for messages.

# Scaling-group.tf (task 5, 7, 8)
This file creates the whole AutoScaling Group, with the name "YourAutoScalingGroup". It has an initial capacity of 0, a min size of 0 and a max size of 4, so at the beginning no Instances will be created. 
Once the SQS threshold for the metric "ApproximateNumberOfMessagesVisible" is exceeded, 2 new instances from scaling-policy.tf will be created. I put a Linux-like AMI ID, with a t2.micro.
The key_name and associate_public_ip_address were used to install the cloudwatch agent, but for some reasons, if I try to automate the SSH connection to install the cloudwatch agent the autoscaling group won't proprely work, so I decided to remove it.
The user_data simply installs python3 and boto3, then creates the entire consumer-script.py and uses it once created. It will then process the messages in the queue. Works properly.

# Scaling-policies.tf (task 6, optional task 4)
This file creates two CloudWatch Alarms, respectively named SQSMessageCountScaleUp and SQSMEssageCountScaleDown. The threshold have been set to greather than 5 for the first alarms and less than 2. Once one of the threshold is exceeded, the two AutoScaling Policies (ScaleUpPolici, ScaleDownPolicy) will either remove or add EC2 instances. 
I also created a CloudWatch Dashboard for EC2 Metrics, which collects the CPUUtiliazion parameters.

# Bonus add-ons
To create the whole infrastructure, I've used Terraform language to automatically create all requirements.

EC2-Metrics-Dashboard shared = https://cloudwatch.amazonaws.com/dashboard.html?dashboard=EC2-Metrics-Dashboard&context=eyJSIjoidXMtZWFzdC0xIiwiRCI6ImN3LWRiLTA1NDM2OTY4Mzc1MyIsIlUiOiJ1cy1lYXN0LTFfYzBrM1U0WGlyIiwiQyI6IjRqNjZtM2NvcTVmbWtzNzRhOHAyNGt2anNrIiwiSSI6InVzLWVhc3QtMToyODE3OTRjZi03MmVmLTRmNDMtYTUxYi01OGU1OTBhNjBiMjQiLCJNIjoiUHVibGljIn0=

SQS-Metrics-Dashboard shared = https://cloudwatch.amazonaws.com/dashboard.html?dashboard=SQS-Metrics-Dashboard&context=eyJSIjoidXMtZWFzdC0xIiwiRCI6ImN3LWRiLTA1NDM2OTY4Mzc1MyIsIlUiOiJ1cy1lYXN0LTFfYzBrM1U0WGlyIiwiQyI6IjRqNjZtM2NvcTVmbWtzNzRhOHAyNGt2anNrIiwiSSI6InVzLWVhc3QtMTowMjQ3YmQzNi0wNjUwLTQwMjEtOWY1ZS04NzM1MTczNWYxY2UiLCJNIjoiUHVibGljIn0=


# Instruction to operate
To successfully use this infrastructure, please download the repository and follow these steps (Windows-User):
1. Download the repository and locate it on a folder in your Desktop
2. Open cmd.exe (Command Prompt)
3. cd to the directory where you have the files
4. Install terraform, skip if already installed
5. write "Terraform init"
6. Write "Terraform plan", then "Terraform Apply"
7. Write "Yes" when asked
8. Wait until the Infrastrcture gets created
9. This error will pop-up after a while: │ Error: creating Auto Scaling Policy (ScaleUpPolicy): ValidationError: Group YourAutoScalingGroup not found
│       status code: 400, request id: 52054dd0-6320-4afe-b14b-c868c9d7e329
│
│   with aws_autoscaling_policy.scale_up_policy,
│   on scaling-policy.tf line 40, in resource "aws_autoscaling_policy" "scale_up_policy":
│   40: resource "aws_autoscaling_policy" "scale_up_policy" {
│
╵
╷
│ Error: creating Auto Scaling Policy (ScaleDownPolicy): ValidationError: Group YourAutoScalingGroup not found
│       status code: 400, request id: 0f2e0e32-267c-4048-8e22-6ec6649942ed
│
│   with aws_autoscaling_policy.scale_down_policy,
│   on scaling-policy.tf line 53, in resource "aws_autoscaling_policy" "scale_down_policy":
│   53: resource "aws_autoscaling_policy" "scale_down_policy" {
10. Rewrite "Terraform apply", then "yes" when asked (I've no idea why it doesn't apply the first time, but sending it a second time works just fine, applying the CloudWatch Alarms and Automatic Scaling Policy)
11. Once the infrastruture gets created, write "python producer-script.py" and send it more than 5 times
12. Wait until the SQS gets the messages, then check if the CloudWatch Alarm SQSMessageCountScaleUp gets in Alarm
13. Wait until at least 2 instances gets created, then wait until the consumer-script works out and deletes the message in the SQS Queue
14. Done!

Thanks for your time. See you soon!
