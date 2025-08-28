from datetime import datetime

def format_date(date, input_format):
    mid = datetime.strptime(date, input_format)
    result = mid.strftime("%Y-%m-%d")
    return result