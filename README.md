# configurable-api-caller

The Configurable API Caller is designed to be deployed to Lambda. Then through Cloudwatch Rules, it can be scheduled to run jobs against any service the rule is configured to hit. This is a Get call at the moment. This Lambda provides the ability to perform schedulable tasks on all services that expose an endpoint, ie clean up jobs. This is not an easy thing to cron in AWS as we cannot always be sure which instances, or how many, need targeting from a fixed scheduled rule.

Cloudwatch Rules allow for the passing of JSON as part of the event which triggers the Lambda. When defining the target of the rule the option of Constant (JSON text) provides the opportunity to add service configuration.

To avoid putting api key secrets in plaintext within Cloudwatch Rules, the lambda performs a Systems Manager Parameter Store lookup based on the "API_KEY_REF" and "REGION" that value is stored in.

#### Event Constant JSON Input

```json
{
  "API_HOST": "host.domain.name",
  "API_KEY_REF": "/paramstore/api_key_ref",
  "DATA": { "someData": true },
  "ENDPOINT": "/some/resource",
  "IS_SSL": true,
  "HEADERS": { "headers": {
        "Authorization": ""
    }
  },
  "HTTP_VERB": "POST",
  "REGION": "region of param store value"
}
```

##### Default values:

API_HOST: "localhost"<br>
HTTP_VERB: "GET"<br>
REGION: "eu-west-2"<br>
DATA: {}

##### Supported values:

HTTP_VERB: GET/POST/DELETE

Note: <br>Pipeline still in progress. Project is packaged from root folder.<br>
rm configurable-api-caller.zip (Get rid of any existing artifacts)<br>
tsc (compile typescript)<br>
zip -rq configurable-api-caller ./* -x '\*terraform\*' (zip up, excluding terraform scripts)

##### Running Terraform:

The terraform is applied using the terraform-runner. Example command:

`terraform-runner -g configurable-api-caller -c plan`
