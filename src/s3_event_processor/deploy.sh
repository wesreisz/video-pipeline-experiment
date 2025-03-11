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

# Create a fresh deployment package
cd "${SCRIPT_DIR}"
zip -r "${ZIPFILE}" ./*.py

echo "Lambda package created at ${ZIPFILE}"
echo "Done." 