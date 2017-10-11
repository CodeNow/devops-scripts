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
      psad_logs="${psad_logs}$(sed '/Whois Information/,$d' ${log_file})"
    done

    data_file=`tempfile`
    echo "generating data file at ${data_file}"
    echo '{' > ${data_file}
    echo '"containerId": "'"${container_id}"'",' >> ${data_file}
    echo '"hostnames": "'`hostname -I | cut -d' ' -f1`'",' >> ${data_file}
    echo '"logs": "'${psad_logs}'"'>> ${data_file}
    echo '}' >> ${data_file}

    echo "sending alert" `cat ${data_file}`
    curl --header "Content-Type: application/json" \
      -X POST \
      --data "@${data_file}" \
      "http://{{ drake_hostname }}/psad"

     rm "${data_file}"
  fi
done
