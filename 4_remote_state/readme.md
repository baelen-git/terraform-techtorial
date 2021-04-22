# CLEANUP 
Remove the backend piece of code from main.tf
```
tf init
```

Empty your S3 bucket
Clear your DynamoDB database
# SCRIPT 
## setup
1. create an aws user account
2. setup aws configure
3. create a bucket

## admin-1 
Add this piece of code to your main.tf
```
  backend "s3" {
    bucket = "pvt-tf-state"
    key    = "terraform.state"
    region = "eu-central-1"
    encrypt  = true
    dynamodb_table = "terraform"
  }
```
Terraform will migrate the state file to your S3 bucket when you run tf init
```
tf init
tf plan
rm -rf 
terraform.tfstate.d
tf plan
```
show the AWS console and show that we have
- encryption
- versioning
- locking
```
tf plan #at the same time from both accounts
```
