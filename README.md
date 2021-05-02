# CLEANUP 
```
tf destroy -auto-approve
sudo rm -rf /terraform
rm -rf ~/boris/*
rm -rf ~/riccardo/*
aws s3 rm s3://pvt-tf-state/ --include "*" --recursive
aws dynamodb delete-table --table-name terraform
aws dynamodb create-table --table-name terraform --key LockID --attribute-definitions '{ "AttributeName" : "LockID", "AttributeType" : "S"  }' --key-schema '{ "AttributeName" : "LockID", "KeyType" : "HASH" }' --provisioned-throughput '{ "ReadCapacityUnits" : 5, "WriteCapacityUnits": 5}'
gh api  -X DELETE repos/baelen-git/pvt-emear-demo
sudo iptables -D OUTPUT -d emear-secrets.cisco.com -j REJECT
```

# SETUP
1. On local host
```
git clone https://github.com/baelen-git/terraform-techtorial
cd terraform-techtorial/1_team_collaboration/
mv terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
cp * ~/boris
```
2. create a management workstation
3. create 2 users
4. create an admin group
5. make all 3 users members of the admin group and make this their primary group
```
export TF_VAR_vault_token="sometoken"
```
1. Upgrade git to the latest version so we can specify a defaultBranch
```
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get upgrade
git config --global init.defaultBranch main
```


# TEAM COLLABORATION 
## admin-1 
show the code 
```
cd boris
vi main.tf
vi terraform.tfvars
vi variables.tf
tf init
```
show the .terraform directory and the .lock.hcl file
```
tf plan
tf apply -auto-approve
```
Deploy will take ~ 1 minute, show vCenter. 
Boris now goes on a holiday but before he leaves he shares his code with the Team.
```
cp main.tf terraform.tfvars variables.tf ../riccardo
```

## admin-2
Admin-2 get's complains about the performance of the VM.  
He has received the terraform code from his college but doesn't know much about terraform yet.   
He changes the vCPU and runs the code.  
-> show the code, same config but with 4 vCPU  
```
tf init
tf plan
```
Now a good admin would stop here and think, huh? Why would I create a new VM, I don't want that.  
But let's say he does continue with his plan.
```
tf apply -auto-approve
```
Luckily; the plan will fail with the error: "VM Already exists"  
We need to import the VM
```
tf import vsphere_virtual_machine.vm /Amsterdam/vm/PVT-EMEAR/vm-ubuntu-demo
```
Now we can execute the change and add the vCPU
```
tf plan
tf apply -auto-approve
```

## admin-1
Admin 1 comes back from his holiday and want to do a change.
Add or uncomment this piece of code
```
  disk {
    label = "disk1"
    size  = 5  
  }
```
run a terraform plan and apply and when doing this change, youm miss the message that the CPU's have changed and this is now being rolled back.
```
tf plan
tf apply -auto-approve
```

## admin-2
Admin-2 get complains again that the VM has reduced performance again.  
He looks in vCenter and sees that there the vCPUs have been reduced again.  
He runs his terraform plan again to fix the problem
```
tf plan
tf apply -auto-approve
```

He now has deleted the disk that have been added.  
The output that informed him of this was not very clear, it was an orphaned_disk according to terraform.

## admin-1 
Let's setup the mgmt station
```
sudo mkdir /terraform
sudo chgrp admins /terraform/
sudo chmod g+w /terraform
sudo setfacl -m "default:group::rwx" /terraform
cd /terraform
```
copy the your terraform directory to the management station
```
scp -r * baelen@10.61.124.222:/terraform
```
on the management station:
```
cd /terraform
tf init
tf plan
tf apply -auto-approve
chmod g+w *
chmod g+w .terraform*
```

## admin-2
Admin-2 get's complains about the performance of the VM.  
-> Change the vCPU from 2 to 4  
```
vi main.tf
tf apply
```
Everything works as expected 2 users can manage the same environment.  

## admin-1
Admin-1 can do changes without messing up eachothers work
```
tf apply 
```

# VERSION CONTROL

## admin-1 
Let's start using git
```
git init
cp ~/terraform-techtorial/.gitignore .
git add * .gitignore .terraform.lock.hcl
git commit -m "initial commit"
```
Now we are tracking our changes!  
Let's start by fixing that ugly mistake we made.
-> change the vCPU back to 4
```
tf apply
git status
git commit -a -m "fixed the #cpus"
```

You can see the change you did with
```
git log
git show
```


## admin-2
Admin- is not so happy about that last disk that got added and wants to rollback

```
git log
git reset --hard HEAD^
git log
vi main.tf
tf apply
```

Now Admin-1 is editing the main.tf file and keeps it open.
```
vi main.tf
```

## admin-2
Admin-2 wants to increase the size of the disk
```
vi main.tf
tf apply
git commit -a -m "increased the disksize of disk1"
```

## admin-1
Admin-1 is done editing and he wants to save his file
```
WARNING: The file has been changed since reading it!!!
Do you really want to write to it (y/n)?
```

ERROR: both admins working from the same file can create problems.  
Let's start using remotes.  

Create a new repo on [github.com] with the name pvt-emear-demo
- add Riccardo as a Contributor 
Push your git repo
```
git remote add origin https://github.com/baelen-git/pvt-emear-demo.git
git push -u origin main
```

now we can go and checkout our own version of the code on our own laptop.
```
git clone https://github.com/baelen-git/pvt-emear-demo
```

## admin-2
Admin-2 also wants to work on the same file
```
git clone https://github.com/baelen-git/pvt-emear-demo
```

## admin-1
New workflow for doing a change
```
cd pvt-emear-demo
vi main.tf
git commit -a -m "added a disk"
git push
```
Now login to the Terraform server and execute your code.
```
ssh admin1@tfserver
cd /terraform/
git pull 
tf apply 
```

## admin-2
```
cd pvt-emear-demo
vi main.tf
git commit -a -m "changed the cpus"
git push
```
You will get an error because there are changes in the repository that you don't have yet
```
git pull 
vi main.tf
git log
git diff HEAD~2 HEAD
```
Now login to the Terraform server and execute your code.
```
ssh admin1@tfserver
cd /terraform/
git pull 
tf apply 
```

# SECURITY - Remote State
## admin-1 
1. Show that there is sensitive data in the statefile
```
tfserver
cd /terraform
ls -l
vi terraform.state
```

2. Go in the browser and show that there are different backends and that S3 supports version,locking and encryption

3. Show the S3 bucket in AWS and show encryption and the dynamoDB for  

4. Add this piece of code to your main.tf
```
  backend "s3" {
    bucket = "pvt-tf-state"
    key    = "terraform.state"
    region = "eu-central-1"
    encrypt  = true
    dynamodb_table = "terraform"
  }
```

5. run aws configure to connect to your aws bucket
```
aws configure
```

6. commit to git and re-init
Terraform will migrate the state file to your S3 bucket when you run tf init
```
git commit -a -m "added a remote state"
git push
tfserver
cd /terraform
git pull 
tf init
```
7. remove the local state 
```
rm -f terraform.tfstate*
tf plan
```
8. show the AWS console and show that we have
- encryption
- versioning
- locking
9. show that we have state file locking by running a plan at the same time
```
tf plan 
```

# SECURITY - Vault
## scenario 1 
In this scenario we will store credentials in a secure way using Vault.
In the terraform.tfvars we have credentials stored in plain text, also if credentials are going to change all team members will have to update their tfvars. With Vault we can keep it centralized and secure.

```
First show the Credentials in the Vault
```

Now change the code in a coupe of simple steps.

1. Add this block to the providers list
```
    vault = {
      source = "hashicorp/vault"
      version = "2.19.0"
    }
```
2. Configure the Provider
```
provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}
```
3. Download your vsphere credentials from the Vault
```
data "vault_generic_secret" "vsphere" {
  path = "pvt21/vsphere_credentials"
}
```
4. Modify the vsphere Provider to start using those credentials
```
  user                 = data.vault_generic_secret.vsphere.data.username
  password             = data.vault_generic_secret.vsphere.data.password
  vsphere_server       = data.vault_generic_secret.vsphere.data.hostname
```
5.  Specify the Variables you want to use and remove the ones you don't need anymore
```
delete: the vsphere credentials
add
variable "vault_address" {
  type = string
  description = "Vault URL"
}

variable "vault_token" {
  type = string
  description = "Vault authentication token"
}
```
6. Push your code to to the repo
```
git commit -a -m "using Vault for Credentials"
git push
tfserver
cd /terraform
git pull
```

7. remove the credentials from your tfvars file
```
vi terraform.tfvars
delete: vsphere user and password
uncomment: vault_address 
```

Now execute your code to test if this works
```
export TF_VAR_vault_token="edede" 
tf init
tf plan
```

Increase the disk size
```
vi main.tf
tf apply 
git commit -a -m "increased the disk size"
git push
```

## scenario 2
We simulate a fault in the Vault instance
```
sudo iptables -A OUTPUT -d emear-secrets.cisco.com -j REJECT
```

The user wants to change the CPU to 4 (change code)

Rerun automation
```
tf init
tf plan
tf apply -auto-approve
```

Now everything is broken and no automation can be applied

# JENKINS

1. Copy over the Jenkins file and show it on your workstation
```
cp ~/Jenkinsfile .
vi Jenkinsfile
git add Jenkinsfile
git commit -a -m "Added a Jenkinsfile"
```
2. Do a change and push the changes to the git repo 
```
vi main.tf
git commit -a -m "decreased the CPUs"
git push
```
3. Log into Jenkins and kick off the workflow
Show that the VM has been modified

4. Now go back in the code and show the CLI commands that are getting executed
Change the outofdate with the code below
```
outofdate=`terraform  --version | { grep "outdated!" || true; }`
```
5. commit and execute again
```
git commit -a -m "changed the version check"
git push
```
Kick off the pipeline and see what happens.
