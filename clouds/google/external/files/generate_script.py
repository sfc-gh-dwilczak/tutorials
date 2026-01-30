import csv
import os
from faker import Faker
from datetime import datetime, timedelta
import random

# Settings
output_folder = 'customers'
num_files = 5
rows_per_file = 100
csv_headers = ['customer_id', 'first_name', 'last_name', 'email', 'created_at']

# Create output folder
os.makedirs(output_folder, exist_ok=True)

# Initialize Faker for fake data
fake = Faker()

# Helper to generate a datetime within the last year
def random_datetime_within_last_year():
    now = datetime.now()
    past = now - timedelta(days=365)
    return fake.date_time_between(start_date=past, end_date=now)

# Generate CSV files
for _ in range(num_files):
    timestamp_str = datetime.now().isoformat().replace(":", "-").replace(".", "-")
    file_path = os.path.join(output_folder, f'{timestamp_str}.csv')

    with open(file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(csv_headers)

        for i in range(rows_per_file):
            customer_id = i + 1
            first_name = fake.first_name()
            last_name = fake.last_name()
            email = fake.email()
            created_at = random_datetime_within_last_year().isoformat()
            writer.writerow([customer_id, first_name, last_name, email, created_at])

print(f"{num_files} CSV files created in folder: {output_folder}")
