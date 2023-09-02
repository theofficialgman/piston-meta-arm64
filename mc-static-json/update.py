# python script to update the sha1 and size of each input in the json

import json
import requests
import hashlib

# Function to download a file and return its SHA1 hash and size
def download_file(url):
    response = requests.get(url)
    if response.status_code == 200:
        content = response.content
        sha1 = hashlib.sha1(content).hexdigest()
        size = len(content)
        return sha1, size
    return None, None

# Load the JSON data from the input file
input_file = 'input.json'
with open(input_file, 'r') as f:
    data = json.load(f)

# Iterate through libraries
for library in data['libraries']:
    for download_type, downloads in library['downloads'].items():
        if download_type == 'artifact':
            url = downloads['url']
            sha1, size = download_file(url)
            if sha1 and size:
                downloads['sha1'] = sha1
                downloads['size'] = size
        elif download_type == 'classifiers':
            for classifier, classifier_downloads in downloads.items():
                url = classifier_downloads['url']
                sha1, size = download_file(url)
                if sha1 and size:
                    classifier_downloads['sha1'] = sha1
                    classifier_downloads['size'] = size
        elif download_type == 'sources':
            url = downloads['url']
            sha1, size = download_file(url)
            if sha1 and size:
                downloads['sha1'] = sha1
                downloads['size'] = size

# Save the updated JSON data
output_file = 'output.json'
with open(output_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f'Updated JSON data saved to {output_file}')