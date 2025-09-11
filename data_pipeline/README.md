# Data Pipeline for Outbreak Data

The `data_pipeline` folder contains an automated data pipeline that scrapes data from the source URLs and converts it into a JSON file matching the accepted `outbreaks.json` format from [avianfluapp](https://github.com/UMassCDS/avianfluapp).

## Local Development

### Prerequisites

1. Switch to the `data_pipeline` directory:

   `cd data_pipeline`

2. Create a python virtual environment:

   `python -m venv dataenv`

3. Activate the virtual environment:

   `source dataenv/bin/activate` on MacOS / Linux

   `dataenv/Scripts/Activate` on Windows (Powershell)

4. Install dependencies:

   `pip install -r requirements.txt`
   
5. Install [Chromedriver](https://developer.chrome.com/docs/chromedriver/get-started). The Chromedriver must be compatible with the current Chrome version.
6. Set the `CHROMEDRIVER_PATH` variable in `src/constants/environment_constants.py` to the path of the `chromedriver.exe` file
7. Run `chmod +x run_pipeline.sh` to make the `run_pipeline.sh` script executable

### Run Pipeline Locally

1. Run `./run_pipeline.sh` to run the pipeline.

This will generate 3 JSON files in `/data/processed_data/` for each data source. JSON files are overwritten by default. Currently, the jitter is re-calculated every time the pipeline is run.

## Docker Deployment

### Build and Test Locally

1. Build the Docker image:
   ```bash
   docker build -t bird-flow-pipeline .
   ```

2. Test the container locally:
   ```bash
   docker run --rm bird-flow-pipeline
   ```

3. Verify output files are created:
   ```bash
   docker run --rm bird-flow-pipeline sh -c "ls -la /app/data/scraped_data/ && ls -la /app/data/processed_data/"
   ```

### Push to AWS ECR

1. **Login to ECR**:
   ```bash
   aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 091733705266.dkr.ecr.us-east-2.amazonaws.com
   ```

2. **Tag the image**:
   ```bash
   docker tag bird-flow-pipeline 091733705266.dkr.ecr.us-east-2.amazonaws.com/bird-flow-pipeline:latest
   ```

3. **Push to ECR**:
   ```bash
   docker push 091733705266.dkr.ecr.us-east-2.amazonaws.com/bird-flow-pipeline:latest
   ```

### AWS Deployment Steps

After pushing the Docker image to ECR, deploy using AWS Console:

1. **Create S3 Bucket**: `bird-flow-data-bucket` in `us-east-2`
2. **Create CloudWatch Log Group**: `/ecs/bird-flow-pipeline`
3. **Update IAM Role Trust Policy**: Allow `ecs-tasks.amazonaws.com` to assume `avian-flu-scheduler` role
4. **Create ECS Task Definition**: Use the provided `task-definition.json`
5. **Create ECS Cluster**: `bird-flow-cluster` (Fargate)
6. **Create EventBridge Schedule**: Daily execution using the ECS task

### Output

When deployed, the pipeline will:
- Scrape fresh data from USDA websites
- Process and geocode the data
- Upload timestamped JSON files to S3:
  ```
  s3://bird-flow-data-bucket/outbreak_data/latest/wild_birds_YYYYMMDD_HHMMSS.json
  s3://bird-flow-data-bucket/outbreak_data/latest/poultry_YYYYMMDD_HHMMSS.json
  s3://bird-flow-data-bucket/outbreak_data/latest/bovine_YYYYMMDD_HHMMSS.json
  ```
