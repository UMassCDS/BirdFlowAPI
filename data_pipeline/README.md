# Data Pipeline for Outbreak Data

The `data_pipeline` folder contains an automated data pipeline that scrapes data from the source URLs and converts it into a JSON file matching the accepted `outbreaks.json` format from [avianfluapp](https://github.com/UMassCDS/avianfluapp).

## Prerequisites

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

## Run Pipeline

1. Run `./run_pipeline.sh` to run the pipeline.

This will generate 3 JSON files in `/data/processed_data/` for each data source. JSON files are overwritten by default. Currently, the jitter is re-calculated every time the pipeline is run.

## Running and Testing the Data Pipeline Locally in Docker

```
docker build -t bird-flow-pipeline .
docker run --rm bird-flow-pipeline
```

## How Files are stored?
For each .json file in data/processed_data/, two uploads happen:
Versioned (history) upload:
- The file is uploaded to S3 under outbreaks/history/{base_filename}_{timestamp}.json
- Example: outbreaks/history/bovine_20251015_235959.json
This keeps a historical record of every upload with a unique timestamp.

Root (latest) upload:
- The same file is uploaded to S3 under outbreaks/{filename}
- Example: outbreaks/bovine.json
This always contains the latest version and is overwritten each time.

All historical versions are kept in outbreaks/history/ with timestamps. The latest version is always at outbreaks/{filename}.

## Documentation

For a detailed overview of the BirdFlow Automated Data Pipeline architecture and deployment, see the [BirdFlow Automated Data Pipeline Architecture documentation](https://umass-cds-ai.atlassian.net/wiki/spaces/HOME/pages/1018200065/BirdFlow+Automated+Data+Pipeline+Architecture).

