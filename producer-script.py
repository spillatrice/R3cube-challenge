import boto3
import json

# Create SQS client
sqs = boto3.client('sqs')
#Replace queue_url with your actual SQS queue url
queue_url = 'https://sqs.eu-west-1.amazonaws.com/054369683753/R3CUBE-Queue'

# Send message to SQS queue
response = sqs.send_message(
    QueueUrl=queue_url,
    DelaySeconds=10,
    MessageAttributes={
        'Vehicle': {
            'DataType': 'String',
            'StringValue': 'VH2001'
        },
        'Make': {
            'DataType': 'String',
            'StringValue': 'Honda'
        },
         'Model': {
            'DataType': 'String',
            'StringValue': 'Civic'
        },
       'Year': {
            'DataType': 'Number',
            'StringValue': '2020'
        },
         'Color': {
            'DataType': 'String',
            'StringValue': 'Blue'
        },
        'Mileage': {
            'DataType': 'Number',
            'StringValue': '15000'
        }
    },
    MessageBody=(
        'Information about the vehicle'
    )
)

print(response['MessageId'])

# Check if the message was sent successfully
if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    print("Message sent successfully!")
    print("Message ID:", response['MessageId'])
else:
    print("Failed to send message.")
    print("Response:", response)