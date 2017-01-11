#!/bin/bash

alerted_ipaddress="${1}"
echo "looking for container with ip = ${alerted_ipaddress}"

for container_id in $(docker ps -qa); do
  container_ipaddress="$(docker inspect --format "{{ '{{' }} .NetworkSettings.IPAddress {{ '}}' }}" ${container_id})"
  echo "checking ${container_id}: ${container_ipaddress}"

  if [[ "${container_ipaddress}" == "${alerted_ipaddress}" ]]; then
    psad_logs=""
    psad_logs_files="$(ls /var/log/psad/$alerted_ipaddress/*_email_alert)"
    echo "found container_id, getting logs for ${container_id}: ${container_ipaddress} from ${psad_logs_files}"

    for log_file in "${psad_logs_files}"; do
      psad_logs="${psad_logs} \n\n $(sed '/Whois Information/,$d' ${log_file})"
    done

    echo "sending alert for ${container_id}"
    curl --header "Content-Type: application/json" \
      -X POST \
      --data '{"containerId":"'${container_id}'","logs":"'${psad_logs}'"}' \
      "http://{{ drake_hostname }}/psad"
  fi
done
