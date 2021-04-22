# CLEANUP 
```
git reset --hard HEAD^
tf apply -auto-approve
rm -rf .git
delete your git repo
rm -rf pvt-emear-demo/
rm -rf pvt-emear-demo/
```

# SCRIPT 
## setup
1. Upgrade git to the latest version so we can specify a defaultBranch
```
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get upgrade
git config --global init.defaultBranch main
```

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
Admin-2 needs to add a disk to the code.  
```
vi main.tf
#uncommonent the disk section
tf apply
git commit -a -m "added a disk"
git log
```
Here you can see the changes are tracked

## admin-1
Admin-1 is not so happy about that last disk that got added and wants to rollback

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
