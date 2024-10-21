#!/bin/bash

set -e  # Exit on command errors

python /app/download.py

# Terminate the script after cloning/pulling
exit 0
