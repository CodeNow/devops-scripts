devops-scripts
==============

Scripts for managing our deployments.

# How to Deploy at Runnable
## Setup

Before you can deploy you'll need to install the appropriate tools, scripts, and keys on your local machine.
To do so, execute the following steps:

1. Install Ansible (the deploy automation tool we use to deploy projects to production)
http://docs.ansible.com/intro_installation.html

2. Get the latest devops-scripts (the recipes that we use to deploy various projects)
https://github.com/CodeNow/devops-scripts

3. Change to the devops scripts repo directory and run the following command:
`ln -s /<local-path-to-devops-scripts>/ssh/config ~/.ssh/config`

4. Obtain the “Keys of Power” from someone who can already deploy (ask Anand if you don’t know). Depending on what you want to deploy you'll receive either `Test-runnable.pem`, `oregon.pem`, or both.

5. Move the “Keys of Power” .pem  files to your `~/.ssh` directory

At this point you should be capable of deploying;
keep reading to find out how to actually perform a deploy!

## Deploying

### Step 1: Determine the Current Deploy Version
**IMPORTANT:** always pull latest devopts-scripts!!
**IMPORTANT:** Before you deploy a new version of any project make sure to determine which version of the project is currently deployed. This way you can quickly revert to the last stable release if something goes wrong after pushing a new version.

Currently the easiest way to determine the current deploy version is to check the latest tag in the repository you are pushing. Note: If you just tagged a new release this would be the second latest tag.

Once you've found the correct tag, copy it down somewhere that is easily and quickly accessible, then continue your quest of deployment...

### Step 2: Deploy the Project via Ansible
**WARNING:** If you were unable to determine the last deploy tag for a project and cannot revert STOP HERE. Ask someone on the team for help before continuing.

From the devops-script/ansible directory here's how to deploy:
```
ansible-playbook -i ./[stage-hosts, prod-hosts] [appname].yml
```
`stage-hosts` is to deploy to staging, `prod-hosts` is to deploy to production
`appname` is what you want to deploy
this command builds and deploys master branch

```
ansible-playbook -i ./[stage-hosts, prod-hosts] [appname].yml -e git_branch=some_brach_or_tag
```
Use above to deploy a specific tag or branch or release
For tags use: `-e git_branch=v1.9.9`
For branches use: `-e git_branch=that_branch`
For a specific commit use: `-e git_branch=3928745892364578623`

```
ansible-playbook -i ./[stage-hosts, prod-hosts] [appname].yml -t deploy -e git_branch=some_brach_or_tag
```
This will redeploy the current deploy without rebuilding

```
ansible-playbook -i./[stage-hosts, prod-hosts] [appname].yml -e git_branch=some-branch-name -e build_args=”--no-cache”
```

deploy latest version of the branch

## Reverting

If, for some reason, the new deploy is not operating as expected you can quickly revert by referencing the tag you collected in Step 1. Simply run the appropriate deploy command in the previous section with the last release tag and the new deploy will be reverted.

## Deploy Songs

It is the custom at Runnable to play a song to the entire team when deploying. For each of the repositories here are the respective songs:

[api: Push it - Rick Ross](https://www.youtube.com/watch?v=qk2jeE1LOn8)

[runnable-angular: Push it to the limit - Scarface](https://www.youtube.com/watch?v=9D-QD_HIfjA)

[mavis: Fairy Tail theme song](https://www.youtube.com/watch?v=kIwmrk7LoDk)

[khronos: Time After Time - Cyndi Lauper](https://www.youtube.com/watch?v=VdQY7BusJNU)

[navi: Ocarina of Time: Lost Woods The Legend of Zelda](https://www.youtube.com/watch?v=iOGpdGEEcJM)

[optimus: Original Transformers opening theme](https://www.youtube.com/watch?v=nLS2N9mHWaw)

[charon: Enter Sandman - Metallica](https://www.youtube.com/watch?v=CD-E-LDc384)

[docker listener: Call Me Maybe - Carly Rae Jepsen](https://www.youtube.com/watch?v=fWNaR-rxAic)

[krain: men at work - down under](https://www.youtube.com/watch?v=XfR9iY5y94s)

[filibuster: He's a Pirate - Pirates Of The Caribbean](https://www.youtube.com/watch?v=yRh-dzrI4Z4)

[shiva: FFXIV Shiva Theme](https://www.youtube.com/watch?v=noJiH8HLZw4)

[swarm-manager: Eric Prydz VS Pink Floyd - 'Proper Education'](https://www.youtube.com/watch?v=IttkDYE33aU)

[swarm-deamon: Pink Floyd - Another Brick In The Wall](https://www.youtube.com/watch?v=5IpYOF4Hi6Q)

**IMPORTANT:** Make sure the play the song loud and proud when deploying!
