TEST_FN=`util::get_latest_tag api 2>/dev/null`
if [ -z "$TEST_FN" ]; then
  echo 'missing util function, run this like so ". ./stack-create.sh"'
  exit 1
fi

for APP in agreeable-egret api arithmancy big-poppa clio cream detention docker-listener drake eru github-varnish ingress-proxy khronos link mongo navi-proxy navi optimus palantiri pheidi prometheus-alerts prometheus rabbitmq registry sauron swarm-manager navi-port-router; do
  GIT_BRANCH=`util::get_latest_tag $APP 2>/dev/null`
  if [ -z "$GIT_BRANCH" ]; then
    echo - include: $APP.yml
  else
    echo - include: $APP.yml -e git_branch="$GIT_BRANCH"
  fi
done

# add speical cases
echo - include: shiva.yml -e git_branch=`util::get_latest_tag astral 2>/dev/null`
echo - include: swarm-cloudwatch-reporter.yml -e git_branch=v2.0.0
