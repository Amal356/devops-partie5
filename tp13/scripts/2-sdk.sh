#!/usr/bin/env bash
# TP13 partie 2 : SDK JavaScript v3 contre Floci (S3 + message SQS), puis lecture avec AWS CLI.
set -euo pipefail
export AWS_PROFILE=floci
cd ~/tp13/sdk-demo
npm install --no-audit --no-fund --silent
QURL=$(cat ~/tp13/queue-url.txt)
echo "========== npm start (QUEUE_URL=$QURL) =========="
QUEUE_URL="$QURL" npm start --silent
echo; echo "========== Lecture du message avec AWS CLI =========="
aws sqs receive-message --queue-url "$QURL" --max-number-of-messages 5 --query 'Messages[].Body' --output text
