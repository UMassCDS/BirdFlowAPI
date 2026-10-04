from datetime import datetime

def format_date(date, potential_formats):
    for fmt in potential_formats:
        try:
            mid = datetime.strptime(date, fmt)
            result = mid.strftime("%Y-%m-%d")
            return result
        except ValueError:
            continue
    raise ValueError("Date {} format not recognized as one of potential formats: {}".format(date, potential_formats))