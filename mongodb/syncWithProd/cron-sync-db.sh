# add ssh key
ssh-add ~/.ssh/runnablevpc.pem;
sshAddExitCode=`echo $?`;
if [ "$sshAddExitCode" -eq "0" ]
then
  echo "ssh-add successful"
else
  echo "ssh-add failed, restarting ssh agent";
  export SSH_AGENT_PID=$(ps ax | grep [s]sh-agent | awk '{print $1}');
  if [ ! -z "$SSH_AGENT_PID" ]
  then
    echo 'ssh agent killed';
    killall ssh-agent
  fi
  echo 'ssh agent started';
  eval `ssh-agent`;
  export SSH_AGENT_PID=$(ps ax | grep [s]sh-agent | awk '{print $1}');
  ssh-add ~/.ssh/runnablevpc.pem;
fi
# create ssh tunnel
ssh -S my-ctrl-socket -O check ubuntu@mongodb
socketExitCode=`echo $?`;
if [ "$socketExitCode" -eq "0" ]
then
  echo 'ssh tunnel is open to mongodb on port 37017';
else
  echo 'opening ssh tunnel to mongodb on port 37017';
  ssh -M -S my-ctrl-socket -fnNT -L 37017:localhost:27017 ubuntu@mongodb;
fi
# clone database
mongo runnable2 mongoCloneDatabase.js;
# close ssh tunnel
ssh -S my-ctrl-socket -O exit ubuntu@mongodb;
# remove key
ssh-add -D ~/.ssh/runnablevpc.pem;