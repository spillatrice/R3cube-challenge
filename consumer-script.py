import boto3
import json
import time

# Replace queue_url with your SQS queue
region_name = 'eu-west-1'
queue_url = 'https://sqs.eu-west-1.amazonaws.com/054369683753/R3CUBE-Queue'

# Initialize SQS client
sqs = boto3.client('sqs', region_name=region_name)

def process_message(message):
    try:
        data = json.loads(message['Body'])
        print(f"Processing message: {json.dumps(data)}")
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        print(f"Invalid message content: {message['Body']}")
    except KeyError as e:
        print(f"KeyError: {e}")
        print(f"Malformed message: {message}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    if message['Body'] == "Information about the vehicle":
        print("Received information about the vehicle")
        # Handle this specific message content
    else:
        print("Received unknown or unexpected message:", message['Body'])
        # Handle other types of messages or log as necessary


while True:
    # Receive messages from SQS queue
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=20  # Long polling for messages (20 seconds)
    )

    if 'Messages' in response:
        for message in response['Messages']:
            process_message(message)
            
            # Delete the message from the queue after processing
            receipt_handle = message['ReceiptHandle']
            sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=receipt_handle
            )

    # Wait for one minute before polling for messages again
    time.sleep(60)
