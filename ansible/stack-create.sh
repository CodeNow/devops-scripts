for APP in agreeable-egret api arithmancy big-poppa clio cream detention docker-listener drake eru github-varnish ingress-proxy khronos link mongo-navi navi-proxy navi optimus palantiri pheidi prometheus-alerts prometheus rabbitmq redis registry sauron shiva swarm-cloudwatch-reporter swarm-manage; do
  GIT_BRANCH=`util::get_latest_tag $APP 2>/dev/null`
  if [ -z "$GIT_BRANCH" ]; then
    echo - include: $APP.yml
  else
    echo - include: $APP.yml -e git_branch="$GIT_BRANCH"
  fi
done
