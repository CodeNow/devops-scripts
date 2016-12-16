devops-scripts
==============

Scripts for managing our deployments.

# How to Deploy at Runnable
## Setup

Before you can deploy you'll need to install the appropriate tools, scripts, and keys on your local machine.
To do so, execute the following steps:

1. Install Ansible v2.1.0.0 (the deploy automation tool we use to deploy projects to production)
http://docs.ansible.com/intro_installation.html

2. Get the latest devops-scripts (the recipes that we use to deploy various projects)
https://github.com/CodeNow/devops-scripts

3. Change to the devops scripts repo directory and run the following command:
`ln -s /<local-path-to-devops-scripts>/ssh/config ~/.ssh/config`

4. Obtain the “Keys of Power” from someone who can already deploy (ask Anand if you don’t know). Depending on what you want to deploy you'll receive `*.pem` files.

5. Move the “Keys of Power” .pem  files to your `~/.ssh` directory

6. Install two required tools onto your machine:
```bash
brew update && brew install vault daemon
```

At this point you should be capable of deploying; keep reading to find out how to actually perform a deploy!

## Deploying Services
- **IMPORTANT:** always pull latest devopts-scripts (`git pull origin master`)
- **IMPORTANT:** Before you deploy a new version of any project make sure to determine which version of the project is currently deployed. This way you can quickly revert to the last stable release if something goes wrong after pushing a new version.

### Step 1: Determine the Current Deploy Version
To determine the latest deploy tag for a project please check the project's repository on
github and look for the latest release tag (should be in the form `vX.Y.Z`). Once you've located the tag,
copy it down somewhere that is easily and quickly accessible (you may need to use it quickly if something goes wrong).

### Step 2: Deploy the Project via `ansible-playbook`

- **WARNING:** If you were unable to determine the last deploy tag for a project and cannot revert **STOP**.
  Ask someone on the team for help before continuing.
- **IMPORTANT:** All commands should be run from the `devops-script/ansible` directory.

#### Ansible Vault

Please note that there are playbook that require encrypted [ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html) files. If you see the following error:

```bash
ERROR: A vault password must be specified to decrypt # snip
```

you will need to re-run the playbook with:

```bash
--ask-vault-pass
```

#### Latest Tag
Build and deploy a service to the latest tag of its repository. This will build
the docker image needed to run the container on our infrastructure.

#### Branch or Tag
Build and deploy a service to a specific branch or tag on its repository. This performs a build
of the docker image needed to run the service on our architecture.

##### Command
```
ansible-playbook -i ./[inventory_dir] [service-playbook] -e git_branch=[branch-or-tag] -t deploy
```

##### Arguments
- `[inventory_dir]` - The environment inventory files (servers and variables). Should be one of the following:
  - `stage-hosts` - Runnable sandbox staging environment services
  - `gamma-hosts` - Gamma services (internal use only; production mirror)
  - `delta-hosts` - Delta services (real production)
- `[service-playbook]` - The playbook for the service you wish to deploy, ex:
  - `api.yml` - Deploys both the api and the api-workers services
  - `shiva.yml` - Deploys the shiva micro-service
  - `charon.yml` - Deploys a specific version of charon DNS to all docks
- `[branch-or-tag]` - The branch or tag you wish to deploy, ex:
  - `-e git_branch=v1.9.9` (version tag)
  - `-e git_branch=my-feature-branch` (branch)
  - `-e git_branch=3928745892364578623` (specific commit)

##### Rebuild and Deploy Tag or Branch (No Cache)
Forces a rebuild of a docker image for the given service at the given branch or tag and then deploys the
newly created image. This is useful when a previously deployed branch has new changes that need to
be deployed to an environment.

Generally this command is only used with `gamma-hosts/` as it is often used to update code
being tested in the production mirror.

##### Command
```
ansible-playbook -i ./[inventory_dir] [service-playbook] -e git_branch=[branch-or-tag] -e build_args=--no-cache
```

##### Arguments
- `[inventory_dir]` - The environment inventory files (servers and variables).
- `[service-playbook]` - The playbook for the service you wish to deploy.
- `[branch-or-tag]` - The branch or tag you wish to deploy.


## Reverting
If, for some reason, the new deploy is not operating as expected you can quickly revert by referencing the tag you collected in Step 1.
Simply run the appropriate deploy command in the previous section with the last release tag and the new deploy will be reverted.

## Deploy Songs

- **IMPORTANT:** Make sure to play the song loud and proud when deploying!

It is the custom at Runnable to play a song to the entire team when deploying. For each of the repositories here are the respective songs:

| Service | Deploy Song Link |
| ------- | ---------------- |
| api / api-workers | [Push it - Rick Ross](https://www.youtube.com/watch?v=qk2jeE1LOn8) |
| arithmancy | [onerepublic - Counting Stars](https://www.youtube.com/watch?v=hT_nvWreIhg) |
| big poppa | [Big Poppa - The Notorious B.I.G.](https://www.youtube.com/watch?v=phaJXp_zMYM) |
| charon | [Enter Sandman - Metallica](https://www.youtube.com/watch?v=CD-E-LDc384) |
| cream | [C.R.E.A.M. - Wu-Tang Clan](https://www.youtube.com/watch?v=PBwAxmrE194) |
| detention | [Unbreakable Kimmy Schmidt](https://youtu.be/CV9xF8CjhJk?t=21s) |
| docker-listener | [Call Me Maybe - Carly Rae Jepsen](https://www.youtube.com/watch?v=fWNaR-rxAic) |
| drake | [Drake - Hotline Bling](https://www.youtube.com/watch?v=uxpDa-c-4Mc)
| filibuster | [He's a Pirate - Pirates Of The Caribbean](https://www.youtube.com/watch?v=yRh-dzrI4Z4) |
| github-proxy | [Proxy - Martin Garrix](https://www.youtube.com/watch?v=NWB6-PJw4Mk) |
| khronos | [Time After Time - Cyndi Lauper](https://www.youtube.com/watch?v=VdQY7BusJNU) |
| krain | [Men at Work - Down Under](https://www.youtube.com/watch?v=XfR9iY5y94s) |
| link | [Zelda Main Theme Song](https://www.youtube.com/watch?v=cGufy1PAeTU) |
| mavis | [Fairy Tail theme song](https://www.youtube.com/watch?v=R4UFCTMrV-o) |
| navi | [Ocarina of Time: Lost Woods The Legend of Zelda](https://www.youtube.com/watch?v=iOGpdGEEcJM) |
| optimus | [Original Transformers Opening Theme](https://www.youtube.com/watch?v=nLS2N9mHWaw) |
| pheidi | [Chariots of Fire Theme](https://www.youtube.com/watch?v=CSav51fVlKU) |
| runnable-angular | [Push it to the limit - Scarface](https://www.youtube.com/watch?v=9D-QD_HIfjA) |
| sauron | [Sauron theme song from LOTR](https://www.youtube.com/watch?v=V_rk9VBrXMY) |
| Security Groups | [Out of the Woods - Tayor Swift](https://www.youtube.com/watch?v=JLf9q36UsBk)
| shiva | [FFXIV Shiva Theme](https://www.youtube.com/watch?v=noJiH8HLZw4) |
| swarm-deamon | [Pink Floyd - Another Brick In The Wall](https://www.youtube.com/watch?v=5IpYOF4Hi6Q) |
| swarm-manager | [Eric Prydz VS Pink Floyd - 'Proper Education'](https://www.youtube.com/watch?v=IttkDYE33aU) |
| vault / vault-values | [Seal - Kiss From A Rose](https://www.youtube.com/watch?v=zP3so2hY4CM) |
| Full Stack Deploy (`all.yml`) | [The Cleveland Orchestra (George Szell conducting) Ludwig von Beethoven Symphony No. 9 "Chorale (Ode To Joy)" Opus 125 IV.] (https://www.youtube.com/watch?v=4g5770gaais) |
