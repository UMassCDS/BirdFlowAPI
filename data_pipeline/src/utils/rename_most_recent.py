import os

def rename_most_recent(download_dir, new_name):
    '''Renames the most recently downloaded file in the specified directory to a standardized name.'''
    files = [f for f in os.listdir(download_dir)]
    if files:
        files.sort(key=lambda x: os.path.getmtime(os.path.join(download_dir, x)), reverse=True)
        old_file = os.path.join(download_dir, files[0])
        new_file = os.path.join(download_dir, new_name)
        os.rename(old_file, new_file)
        return new_file
    return None