import json
import csv
import boto3

# List to store all the taxi cab ride data
taxi_cab_rides = []

# Create a Kinesis client using boto3
client = boto3.client('kinesis')

# Counter to track the number of messages sent
counter = 0

# Open the CSV file containing taxi ride data
with open('taxi_data.csv', encoding='utf-8') as csv_file:
    # Read the CSV file as a dictionary
    csv_reader = csv.DictReader(csv_file)
    
    # Append each row (ride) to the taxi_cab_rides list
    for row in csv_reader:
        taxi_cab_rides.append(row)

# Iterate through the list of rides to send each one to the Kinesis stream
for ride in taxi_cab_rides:
    # Send the ride data to the Kinesis stream
    response = client.put_record(
        StreamName="<YOUR KINESIS STREAM NAME>",  # Name of the Kinesis stream
        Data=json.dumps(ride),      # Convert ride data to JSON string
        PartitionKey=str(hash(ride['tpep_pickup_datetime']))  # Use hashed pickup datetime as partition key
    )
    
    # Increment the counter for each sent message
    counter += 1
    print('Message sent #' + str(counter))
    
    # Check if the message was not successfully sent
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('Error!')  # Print an error message
        print(response)  # Print the response details