import os
import boto3
import json
from datetime import datetime

def upload_to_s3(local_file_path, s3_key):
    """Upload a file to S3 bucket"""
    s3_client = boto3.client('s3')
    bucket_name = os.getenv('S3_BUCKET_NAME')
    
    if not bucket_name:
        print("S3_BUCKET_NAME environment variable not set. Skipping S3 upload.")
        return False
    
    try:
        s3_client.upload_file(local_file_path, bucket_name, s3_key)
        print(f"Successfully uploaded {local_file_path} to s3://{bucket_name}/{s3_key}")
        return True
    except Exception as e:
        print(f"Error uploading {local_file_path} to S3: {str(e)}")
        return False

def upload_processed_data():
    """Upload all processed JSON files to S3"""
    processed_data_dir = "data/processed_data"
    
    if not os.path.exists(processed_data_dir):
        print(f"Directory {processed_data_dir} does not exist.")
        return
    
    # Get current timestamp for versioning
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    for filename in os.listdir(processed_data_dir):
        if filename.endswith('.json'):
            local_path = os.path.join(processed_data_dir, filename)
            
            # Add timestamp to filename
            base_name = filename.replace('.json', '')
            timestamped_filename = f"{base_name}_{timestamp}.json"
            s3_key = f"outbreak_data/latest/{timestamped_filename}"
            
            upload_to_s3(local_path, s3_key)

if __name__ == "__main__":
    upload_processed_data()