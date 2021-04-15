# CLEANUP 
run this in both directories
```
tf destroy -auto-approve
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

# SCRIPT 
## admin-1 
show the code 
```
tf init
```
show the .terraform directory and the .lock.hcl file
```
tf plan
tf apply -auto-approve
```
Deploy will take 45 seconds.
show vCenter. 

## admin-2
Admin-2 somehow has gotten the terraform code from his college.
He changes the vCPU and runs the code.
-> show the code, same config but with 4 vCPU
```
tf init
tf plan
tf apply -auto-approve
```
The plan will fail with the error: "VM Already exists"
We need to import the VM
```
tf import vsphere_virtual_machine.vm /Amsterdam/vm/PVT-EMEAR/vm-ubuntu-demo
tf plan
tf apply -auto-approve
``
Deploy will take 45 seconds.
show vCenter. 


