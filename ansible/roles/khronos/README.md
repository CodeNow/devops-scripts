Run Khronos CLI tool out of cron once daily.

`tasks/main.yml` - install cron entry to run `/khronos/bin/cli.js` and output to `{{ app_log_dir }}/khonos_cron.log`
