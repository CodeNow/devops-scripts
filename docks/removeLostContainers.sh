for CONT in `ls /var/lib/docker/container`; do
  COUNT=$(grep $CONT ./goodContaienrs | wc -l)
  if [[ "$COUNT" -eq "0" ]]; then
    echo "docker rm $CONT"
  fi
done