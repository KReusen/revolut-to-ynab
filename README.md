# revolut-to-ynab

Send Revolut CSV statements to an email address, to automatically import transactions to You Need a Budget (YNAB).
Duplicate transactions will be ignored. Uses serverless architecture with AWS Lambda, Simple Email Service (SES) and
Simple Storage Service (S3), all virtually for free.

It helps to have some experience with AWS, Terraform, and Python to deploy this project. This project works well for me
so I decided to share it with the world in case it helps someone else too, be it with their journey with Revolut, YNAB,
or AWS.

## How to Use

1. Download a statement from Revolut in Excel format
2. Convert the Excel file to CSV format
3. Send the CSV file to the mail address, ie ynab@import.example.com
4. The transactions will be imported to YNAB

You'll get an email back with the result of the import.

**Note**: if you're using Android and the Excel export opens in Google Sheets, you can simplify the process above by

- pressing the three dots in the top right corner
- choosing "Share & export"
- choosing "Send a copy"
- choosing "CSV (current sheet)"

## How to deploy

Deployment is done with Terraform, through Github Actions.

First, [setup your AWS Account to be used with Github Actions](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)
and create an s3 bucket to store the Terraform state in.

Also make sure that you have a route53 hosted zone for the (root) domain you want to use, and that you have an active
SES receipt rule set. If you don't have an SES receipt rule set, you can create one in the AWS Console or [through
Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_active_receipt_rule_set).

Then, create the following Github Actions secrets with the appropriate values:

- `AWS_GITHUB_ACTIONS_ROLE_ARN`
- `TF_STATE_BUCKET`
- `DOMAIN_NAME` supports subdomains, ie "importer.example.com"
- `ALLOWED_SENDERS` comma seperated email addresses. Mail from other addresses will be ignored
- `YNAB_ACCESS_TOKEN`
- `YNAB_BUDGET_ID`
- `YNAB_ACCOUNT_ID`

Finally, push to the main branch to deploy the application.

## Technology decisions

Hopefully this is only a temporary solution, until YNAB integrates automatically with all Revolut offerings, including
PRO accounts and joint accounts.

The Revolut API is unfortunately not an option, because it only works with business accounts.

The project only uses the Python standard library. External libraries, like `requests`, `aws-lambda-powertools`, and
`pydantic` will make this project slightly easier to read and write, but come with extra complexity in terms of
packaging the (arm64) lambda and of keeping the libraries up to date (forever).

## Improvement ideas / considerations

This project solves my own problem. I'm only interested in importing transactions from one specific Revolut account
into one specific YNAB account. If you're interested in importing transactions from multiple accounts, you should
generalize my solution.

One quality of life improvement could be to immediately accept Excel files by email. This requires however a more
complex setup for installing and zipping extra Python libraries. The current setup doesn't require any extra libraries
and runs entirely on the Python standard library + boto3, already present in AWS Lambda.
