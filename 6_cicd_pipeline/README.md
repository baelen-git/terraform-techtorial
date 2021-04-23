# PVT21 Demo with CI/CD Pipeline

# CLEANUP 
```
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
sudo iptables -D OUTPUT -d emear-secrets.cisco.com -j REJECT
```

# SCRIPT 
## scenario 
In this scenario we will store credentials in a secure way using Vault and leverage Jenkins to build a CI/CD Pipeline.
Thanks to the renite state we can use ephemeral Jenkins container agents to run the automation

- show the code, Jenkinsfile and the pipeline config in Jenkins
- fire up the pipeline and approve the last stage

Deploy will take ~ 2 minute, show vCenter.

## Destroy the resource
We can fire up the pipiline again and instead of approving it we abort it.
We hardcoded in the Jenkinsfile the destruction of the infrastructure, not really production-grade, but we use it as a cleanup action