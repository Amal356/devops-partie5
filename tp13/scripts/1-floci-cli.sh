#!/usr/bin/env bash
# TP13 partie 1 : AWS CLI contre Floci (S3, SQS, DynamoDB, Secrets Manager, Lambda).
set -uo pipefail
export AWS_PROFILE=floci
cd ~/tp13
h(){ echo; echo "========== $* =========="; }

h "Profil : $(aws configure get endpoint_url) (jamais le vrai AWS)"
aws sts get-caller-identity --query Account --output text

h "S3"
aws s3 mb s3://tp13-demo
echo "Bonjour Floci" > hello.txt
aws s3 cp hello.txt s3://tp13-demo/
aws s3 ls s3://tp13-demo/
aws s3 cp s3://tp13-demo/hello.txt -

h "SQS"
QURL=$(aws sqs create-queue --queue-name tp13-demo --query QueueUrl --output text); echo "$QURL"
aws sqs send-message --queue-url "$QURL" --message-body '{"event":"test"}' --query MessageId --output text
aws sqs receive-message --queue-url "$QURL" --query 'Messages[0].Body' --output text

h "DynamoDB"
aws dynamodb create-table --table-name visits --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST --query TableDescription.TableStatus --output text
aws dynamodb put-item --table-name visits --item '{"id":{"S":"1"},"page":{"S":"/accueil"}}'
aws dynamodb put-item --table-name visits --item '{"id":{"S":"2"},"page":{"S":"/contact"}}'
aws dynamodb scan --table-name visits --query 'Items[].[id.S,page.S]' --output text

h "Secrets Manager"
aws secretsmanager create-secret --name tp13/demo/api-key --secret-string 'lab-only-value' --query Name --output text
aws secretsmanager get-secret-value --secret-id tp13/demo/api-key --query SecretString --output text

h "Lambda"
(cd lambda && rm -f function.zip && zip -q function.zip index.mjs)
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
aws lambda create-function --function-name hello --runtime nodejs22.x --handler index.handler \
  --zip-file fileb://lambda/function.zip --role arn:aws:iam::$ACCOUNT:role/lambda-role --query State --output text
aws lambda wait function-active-v2 --function-name hello 2>/dev/null || sleep 10
aws lambda invoke --function-name hello --payload '{"name":"Ada"}' --cli-binary-format raw-in-base64-out out.json --query StatusCode --output text
cat out.json; echo
echo "$QURL" > ~/tp13/queue-url.txt
