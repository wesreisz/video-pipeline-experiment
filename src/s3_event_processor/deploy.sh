#!/bin/bash
set -e

# Script to package Lambda function for deployment
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOY_DIR="${SCRIPT_DIR}/deploy"
ZIPFILE="${DEPLOY_DIR}/lambda_function.zip"

echo "Packaging Lambda function..."

# Create deployment directory if it doesn't exist
mkdir -p "${DEPLOY_DIR}"

# Clean up any existing deployment package
rm -f "${ZIPFILE}"

# Create a temporary directory for dependencies
TEMP_DIR=$(mktemp -d)
pip install -r "${SCRIPT_DIR}/requirements.txt" --target "${TEMP_DIR}" --no-cache-dir

# Create a fresh deployment package
cd "${TEMP_DIR}"
zip -r "${ZIPFILE}" .

# Add the Lambda function code
cd "${SCRIPT_DIR}"
zip -g "${ZIPFILE}" ./*.py

# Clean up
rm -rf "${TEMP_DIR}"

echo "Lambda package created at ${ZIPFILE}"
echo "Done." 