# build and zip 
dotnet-lambda package --configuration Release  --output-package bin/deployment-archive.zip
# create table with stream
aws --endpoint-url=http://localhost:4566 --region=us-east-1 dynamodb create-table --table-name outbox --attribute-definitions AttributeName=messageId,AttributeType=S --key-schema AttributeName=messageId,KeyType=HASH --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10 --query 'TableDescription.LatestStreamArn' --output text
# create lambda role
aws --endpoint-url=http://localhost:4566 iam create-role --role-name lambda-dotnet-ex --assume-role-policy-document '{"Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
# attach lambda role
aws --endpoint-url=http://localhost:4566 iam attach-role-policy --role-name lambda-dotnet-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 
# create lambda function
aws --endpoint-url=http://localhost:4566 --region=us-east-1 lambda create-function --function-name petlambda --zip-file fileb://bin/deployment-archive.zip --handler PetLambda::PetLambda.Function::FunctionHandler --runtime dotnet6 --role "LAMBDA ROLE ARN" --environment 'Variables={ LOCAL_STACK_HOSTNAME=localstack,AWS_REGION=us-east-1,AWS_DEFAULT_REGION=us-east-1,USE_LOCALSTACK=true,FEATURE=petlambda,ENVIRONMENT=local }'
# subscribe lambda to stream arn - which is taken from the 1st output 
aws --endpoint-url=http://localhost:4566 --region=us-east-1 lambda create-event-source-mapping --function-name petlambda --event-source "STREAM ARN" --batch-size 1 --starting-position LATEST