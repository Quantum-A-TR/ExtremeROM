#!/bin/bash

# GoFile upload script

UPLOAD_URL="https://api.gofile.io/uploadFile"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Upload file to GoFile
upload_file() {
    local file_path="$1"
    if [[ ! -f "$file_path" ]]; then
        handle_error "File not found: $file_path"
    fi

    # Make the API call and capture the response
    SERVER_RESPONSE=$(curl -s -F "file=@${file_path}" "$UPLOAD_URL")

    # Output the server response
    echo "SERVER_RESPONSE: $SERVER_RESPONSE"

    # Check for errors in the response
    if [[ -z "$SERVER_RESPONSE" ]]; then
        handle_error "Received empty response from server"
    fi

    # Parse the response
    local response_code=$(echo "$SERVER_RESPONSE" | jq -r '.code')
    if [[ "$response_code" != "200" ]]; then
        handle_error "Error in response: $SERVER_RESPONSE"
    fi

    echo "Upload successful!"
}

# Main script execution
if [[ $# -ne 1 ]]; then
    handle_error "Usage: $0 <file_path>"
fi

upload_file "$1"