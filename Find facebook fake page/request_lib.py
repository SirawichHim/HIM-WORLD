import requests
import pandas as pd
import os

#Your Facebook access token (with the necessary permissions)
access_token = 'ACCESS TOKEN'

#Base URL for the Graph API search endpoint
search_url = "https://graph.facebook.com/v20.0/pages/search"

# File to store collected page IDs in DBFS to prevent duplicate IDs in the next times.
collected_ids_file = '/FILL YOUR DRIVE/collected_page_ids.txt'

# Read previously collected page IDs
if os.path.exists(collected_ids_file):
    with open(collected_ids_file, 'r') as file:
        collected_ids = set(file.read().splitlines())
else:
    collected_ids = set()

# Define the search parameters for the initial page search, if you have only one word can delete this loop
keywords = ['A', 'B']  # List of keywords

all_pages = []

for keyword in keywords:
    params = {
        'access_token': access_token,
        'q': keyword,  # Search query
        'type': 'page',   # Search for pages
        'fields': 'name,id,link',  # Initial fields to retrieve
        'limit': 1000,    # Number of results to retrieve
    }

    # Make a GET request to the search endpoint
    response = requests.get(search_url, params=params)

    # Check if the request was successful
    if response.status_code == 200:
        data = response.json()
        pages = data.get('data', [])
        all_pages.extend(pages)
    else:
        print(f"Failed to retrieve data for keyword '{keyword}': {response.status_code}")
        print(f"Error details: {response.json()}")

# Remove duplicates based on page ID
unique_pages = {page['id']: page for page in all_pages}.values()

# Filter out pages that have already been collected
new_pages = [page for page in unique_pages if page['id'] not in collected_ids]

# Check if any new pages were returned
if new_pages:
    # Create a DataFrame from the new page data
    df = pd.DataFrame(new_pages)

    # Initialize list to store fan count data
    fan_counts = []

    # Loop through each page to retrieve `fan_count` data
    for page_id in df['id']:
        # Construct the URL for each page's details
        page_url = f"https://graph.facebook.com/v20.0/{page_id}?access_token={access_token}&fields=name,fan_count"
        
        # Make the secondary GET request
        page_response = requests.get(page_url)
        
        # Check if the secondary request was successful
        if page_response.status_code == 200:
            page_data = page_response.json()
            
            # Append `fan_count` or 0 if it's missing
            fan_counts.append(page_data.get('fan_count', 0))
        else:
            # Append 0 if the request fails
            fan_counts.append(0)

    # Add the fan count data to the DataFrame
    df['fan_count'] = fan_counts

    # Display the DataFrame with the additional information
    display(df[['name', 'id', 'link', 'fan_count']])

    # Append new page IDs to the collected IDs file
    with open(collected_ids_file, 'a') as file:
        for page_id in df['id']:
            file.write(f"{page_id}\n")
else:
    print("No new pages found for the query.")
