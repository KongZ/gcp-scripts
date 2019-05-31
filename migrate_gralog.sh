#!/bin/bash

token="your_graylog_user_password"

elasticsearch="elasticsearch-master.graylog.svc.cluster.local:9200"
graylog="graylog-master.graylog.svc.cluster.local:9000"
start=`date +%s`
lines=$(curl -sS "${elasticsearch}/_cat/indices?h=status,index,uuid" | grep "close")
while read -r line
do
   status=$(awk '{print $1}' <<< "$line")
   index=$(awk '{print $2}' <<< "$line")
   echo "${index} was ${status}"
   if [ "$status" = "close" ]; then
      o=$(curl -XPOST -u "${token}" -H "X-Requested-By: graylog" "http://${graylog}/api/system/indexer/indices/${index}/reopen")
      echo "$(date) Opened ${index} ${o}"
      sleep 10
      while curl -sS "${elasticsearch}/_cat/shards" | grep "${index}" | grep -v STARTED ;
      do
         sleep 5
         r=$(curl -sS "${elasticsearch}/_cat/shards" | grep "${index}" | grep UNASSIGNED);
         IFS=$'\n'
         for l in $r; do
         p=$(awk '{print $3}' <<< "$l")
         if [[ "$p" =~ "p" ]]; then
            failedIndex=$(awk '{print $1}' <<< "$l")
            failedShard=$(awk '{print $2}' <<< "$l")
            echo "Shards $failedIndex/$failedShard failed"
            c=$(curl -XPOST -u "${token}" -H "X-Requested-By: graylog" "http://${graylog}/api/system/indexer/indices/${index}/close")
            echo "$(date) Closed ${index} ${c}"
         fi
         done
      done
      c=$(curl -XPOST -u "${token}" -H "X-Requested-By: graylog" "http://${graylog}/api/system/indexer/indices/${index}/close")
      echo "$(date) Closed ${index} ${c}"
   fi
done <<< "$lines"
end=`date +%s`
echo "Completed"
echo "Total time $((end-start))"
seconds=$((end-start))
eval "echo Total time $(date -ud "@$seconds" +'$((%s/3600/24/10000)) days %H hours %M minutes %S seconds')"
