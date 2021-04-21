# CLEANUP 
```
tf destroy -auto-approve
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
sudo iptables -D OUTPUT -d emear-secrets.cisco.com -j REJECT
```

# SETUP 
```
export TF_VAR_vault_token="s.DOv90OmrEhtV9nDrdK57YMoj"
```

# SCRIPT 
## scenario 1 
In this scenario we will store credentials in a secure way using Vault.
In the terraform.tfvars we have credentials stored in plain text, also if credentials are going to change all team members will have to update their tfvars. With Vault we can keep it centralized and secure.

show the code and the tfvars
show the Vault secrets in the UI
comment the credentials from the tfvars file

```
tf init
tf plan
tf apply -auto-approve
```
Deploy will take ~ 1 minute, show vCenter.

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