git pull
docker ps -a -q > tmp
TOTAL_NUM_CONT=$(cat tmp | wc -l)
CUR_CNT=0
NUM_RM=0
for CONT in `cat tmp`; do
  CUR_CNT=$((CUR_CNT+1))
  echo "processing $CUR_CNT out of $TOTAL_NUM_CONT"
  COUNT=$(grep $CONT ./goodContainers | wc -l)
  if [[ "$COUNT" -eq "0" ]]; then
    NUM_RM=$((NUM_RM+1))
    docker rm $CONT
  fi
done

echo "COMPLETE STATUS"
echo ""
echo "num containers processed $TOTAL_NUM_CONT"
echo "num containers removed $NUM_RM"
echo "num containers kept " $((TOTAL_NUM_CONT-NUM_RM))
