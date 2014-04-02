if [[ $# -ne 1 ]]; then
	echo "usage ./startDockletAndBouncer.sh <NODE_ENV>"
	echo "where NODE_ENV is one of the following production, staging, integration, development"
fi
sudo pm2 kill
sudo NODE_ENV=$1 pm2 start docklet/bouncer/index.js -n bouncer -i 5
sudo NODE_ENV=$1 pm2 start docklet/lib/index.js -n docklet
echo "bouncer and docklet started"