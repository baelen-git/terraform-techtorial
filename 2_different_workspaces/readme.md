# CLEANUP 
```
tf workspace select test
tf destroy -auto-approve
tf workspace select prod
tf destroy -auto-approve
rm -rf /terraform/* /terraform/.*
```
Change the code back in your main.tf and terraform.tfvars file

# Full Cleanup
```
tf workspace select test
tf destroy -auto-approve
tf workspace select prod
tf destroy -auto-approve
sudo rm -rf /terraform
aws s3 rm s3://pvt-tf-state/ --include "*" --recursive
aws dynamodb delete-table --table-name terraform
aws dynamodb create-table --table-name terraform --key LockID --attribute-definitions '{ "AttributeName" : "LockID", "AttributeType" : "S"  }' --key-schema '{ "AttributeName" : "LockID", "KeyType" : "HASH" }' --provisioned-throughput '{ "ReadCapacityUnits" : 5, "WriteCapacityUnits": 5}'
gh api  -X DELETE repos/baelen-git/pvt-emear-demo
cd terraform_techtorial/1_different_workstations/admin-1
tf destroy -auto-approve
rm -rf .terraform terraform.tfstate* 
cd terraform_techtorial/1_different_workstations/admin-2
tf destroy -auto-approve
rm -rf .terraform terraform.tfstate* 
```
# SCRIPT 
## setup
1. create a management workstation
2. create 3 users
3. create an admin group
4. make all 3 users members of the admin group and make this their primary group
5. git clone https://github.com/baelen-git/terraform-techtorial
6. chgrp -R admins terraform-techtorial
5. sudo setfacl -m "default:group::rw" /terraform

## admin-1 
Initialize your Terraform environment and create your application
```
sudo mkdir /terraform
sudo chgrp admins /terraform/
sudo chmod g+w /terraform
sudo setfacl -m "default:group::rwx" /terraform
cd /terraform
cp ~/terraform.tfvars ~/terraform-techtorial/2_different_workspaces/* .
chmod g+w *
tf init
tf plan
tf apply -auto-approve
```
Application is now deployed from a centralized workstation

## admin-2
Admin-2 get's complains about the performance of the VM.  
-> Change the vCPU from 2 to 4  
```
tf apply
```
Everything works as expected 2 users can manage the same environment.  

## admin-1
Admin-1 can do changes without messing up eachothers work
```
tf apply 
```

Now we will introduce workspaces to create a test environment
After creating the workspace you can see that the plan shows that terraform wants to create a new VM. We should move the statefile into the correct directory
```
tf workspace new prod
mv terraform.tfstate terraform.tfstate.backup terraform.tfstate.d/prod
tf plan
```

Now we will create a test environment.  
```
tf workspace new test
```

Because we want our other team members from the admin group also having permissions on the workspaces we need to give them write access
```
chmod -R g+w .
```

We want our VM to have a different name in test so we need to modify the code to have a different name based on the workspace
```
in main.tf:
name             = "${var.vsphere_vm_name}-${terraform.workspace}
in terraform.tfvars:
vsphere_vm_name = "vm-app"
```

Now we can execute the plan in test and it will create a new VM
```
tf apply
```
Both admins will now work in the test environment until someone changes it.  

## admin-2
Now admin-2 wants to join on building the test environment.  
The workspace that is active is shared among the admins
```
tf workspace list
cat .terraform/environment
```

He logs in, checks the code and runs an apply.
```
tf apply
```

## admin-1
I'm done with the Test environment so I'm gonna switch back to prod
```
tf workspace select prod
```

## admin-2
Admin-2 still thinks he is in the test environment and is not so happy about the amount of resources claimed by the test servers.
He changes the CPU's and runs an apply

```
tf apply
```
OOPS! the admin was not really paying attention!!  
Now the CPU & Storage resources have been changed of the Production environment.  
And it even had to reboot the production host to remove the resources! Big OOPS!


