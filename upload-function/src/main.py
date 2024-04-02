import functions_framework
import os;

from google.cloud import bigquery

# read env variables
project = os.environ.get('BIGQUERY_PROJECT')
dataset = os.environ.get('BIGQUERY_DATASET')

@functions_framework.http
def function_handler(request):
    data = request.get_json()

    # read data from the request body; return 400 if 'gc_url' property is missing
    gc_url = data.get('gc_url')
    if gc_url is None:
        return ("Missing 'gc_url' property in the body. GS URL is required.", 400)

    # read data from the request body; return 400 if 'table' property is missing
    table_name = data.get('table')
    if table_name is None:
        return ("Missing 'table' property in the body. Table is required", 400)

    # prepare BigQuery Table ID
    table_id = f'{project}.{dataset}.{table_name}'

    client = bigquery.Client()

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )

    # load data to Table ID
    load_job = client.load_table_from_uri(gc_url, table_id, job_config=job_config)
    load_job.result()

    # get table and return number of rows
    table = client.get_table(table_id)

    return (f"Loaded {table.num_rows} rows.", 200)

    