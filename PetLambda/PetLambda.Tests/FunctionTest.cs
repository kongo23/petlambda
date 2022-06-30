using Xunit;

using Amazon;
using Amazon.Lambda.Core;
using Amazon.Lambda.DynamoDBEvents;
using Amazon.Lambda.TestUtilities;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using Amazon.Runtime;


namespace PetLambda.Tests;

public class FunctionTest
{
    [Fact]
    public async Task TestLambda()
    {
        var awsCreds = new BasicAWSCredentials("dummy", "dummy");
        var amazonDynamoDbConfig = new AmazonDynamoDBConfig
        {
            ServiceURL = $"http://localhost:4566"
        };
        var client = new AmazonDynamoDBClient(awsCreds, amazonDynamoDbConfig);

        var request = new PutItemRequest
        {
            TableName = "outbox",
            Item = new Dictionary<string, AttributeValue>
                {
                    {
                        "messageId",
                        new AttributeValue {S = "0"}
                    }
                }
        };

        var response = await client.PutItemAsync(request); //fails

        var result = await client.GetItemAsync(new GetItemRequest()
        {
            TableName = "outbox",
            Key = new Dictionary<string, AttributeValue>
            {
                { "messageId", new AttributeValue { S = "0" } }
            }
        });
    }
}