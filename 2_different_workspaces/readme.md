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


