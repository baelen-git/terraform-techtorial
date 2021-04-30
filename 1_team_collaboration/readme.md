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
```

# SETUP
1. On local host
```
git clone https://github.com/baelen-git/terraform-techtorial
cp terraform-techtorial/1_team_collaboration/* ~/boris
cp terraform-techtorial/1_team_collaboration/* ~/riccardo
```
2. create a management workstation
3. create 2 users
4. create an admin group
5. make all 3 users members of the admin group and make this their primary group

# SCRIPT 
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
scp -R 