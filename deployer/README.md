# Deployer
![Deployer](https://cloud.githubusercontent.com/assets/2194285/21335997/6f51847c-c617-11e6-999d-4db7794d6be0.jpg)

## Purpose
Deployer is the application that is in charge of deploying code here at runnable.


## How it works
Deployer is just a runnable wrapper around ansible. It takes jobs from `deploy.requested` exchange and converts them into ansible playbook commands.

