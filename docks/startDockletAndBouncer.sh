sudo pm2 kill
sudo NODE_ENV=production pm2 start docklet/lib/bouncer.js -n bouncer -i 5
sudo NODE_ENV=production pm2 start docklet/lib/index.js -n docklet
sudo pm2 logs
