#!/bin/bash

#Ref: https://github.com/iamdvr/redis-cluster-localdev/

# Settings
STARTPORT=7001
TIMEOUT=2000
NODES=3
REPLICAS=0

redis_image='redis:5.0.6'
network_name='host'
container_name="redis"

# Computed vars
ENDPORT=$((STARTPORT+NODES-1))

# docker run --name my-redis-container_7003 --net host -d redis:5.0.6 --port 7003 --cluster-enabled yes --cluster-node-timeout 2000
# echo 'yes' | docker run  --net host -i  redis:5.0.6 redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 --cluster-replicas  0


start_nodes ()
{
   for nodeport in `seq $STARTPORT $ENDPORT`; do \
     start_cmd="--port $nodeport --cluster-enabled yes --cluster-node-timeout $TIMEOUT --appendonly yes"
     #-p $nodeport:$nodeport 
     cmd="docker run -d --name $container_name-$nodeport --net $network_name $redis_image $start_cmd"
     echo "$cmd"
     sh -c "$cmd"
     echo "created redis cluster node $container_name-$nodeport"
   done 
}

create_cluster ()
{
    cluster_hosts=''

    for nodeport in `seq $STARTPORT $ENDPORT`; do \
      hostip='127.0.0.1'
      echo "IP for cluster node" $container_name-$nodeport "is" $hostip
      cluster_hosts="$cluster_hosts$hostip:$nodeport ";
    done

    echo "cluster hosts "$cluster_hosts
    echo "creating cluster...."
    echo 'yes' | docker run -i --rm --net $network_name $redis_image redis-cli --cluster create $cluster_hosts --cluster-replicas $REPLICAS;
}


start_and_create_cluster ()
{
  start_nodes

  if [ $NODES -gt 2 ]
  then
    create_cluster
  else
    echo "Nodes less than 3. Skipping Cluster Creation, Please update config if Cluster required"
  fi
}

connect_node() 
{
   
   connhostip="127.0.0.1"
     
   if [[ "$NODES" == 1 ]]; then 
     connport=$STARTPORT
   else
     if [[ "$1" == "" ]]; then
       echo -n "Please select one of node port "
       for i in $(seq $STARTPORT $ENDPORT)
       do
         echo -n "$i "
       done
       echo -ne " [ENTER]: "
       read connport
     else
       connport=$((STARTPORT + $1 - 1))
     fi
   fi

   cmd="docker run -it --rm --net $network_name $redis_image redis-cli -c -h $connhostip -p $connport"
   echo "$cmd"
   sh -c "$cmd"   
}

stop_cluster ()
{
      for nodeport in `seq $STARTPORT $ENDPORT`; do \
        echo "Stopping redis Node $container_name-$nodeport"
        docker rm -f $container_name-$nodeport
      done
}

status_cluster ()
{
   docker ps --filter name=$container_name
}

tail_cluster ()
{
   if [[ "$NODES" == 1 ]]; then 
     connport=$STARTPORT
   else
     if [[ "$1" == "" ]]; then
       echo -n "Please select one of node port "
       for i in $(seq $STARTPORT $ENDPORT)
       do
         echo -n "$i "
       done
       echo -ne " [ENTER]: "
       read connport
     else
       connport=$((STARTPORT + $1 - 1))
     fi
   fi
  CMD="docker logs --follow $container_name-$connport"
  echo "$CMD"
  sh -c "$CMD"
}

ARGV="$@"

case $1 in
status)
    echo -e "\nStatus of Redis Cluster...\n"
    status_cluster
    ERROR=$?
    ;;

stop)
    echo -e "\nStopping Redis Cluster...\n"
    stop_cluster
    ERROR=$?
    ;;

start)
    echo -e "\nStarting Redis Cluster...\n"
    start_and_create_cluster
    ERROR=$?
    ;;

client)
    echo -e "Connecting to Redis Cluster..."
    connect_node $2
    ERROR=$?
    ;;

tail)
   tail_cluster $2
   ERROR=$?
    ;;

help)

echo "Usage: $0 [start|stop|status|tail|client]"
echo "start       -- Launch Redis Cluster instances and Create a cluster using redis-trib create."
echo "stop        -- Stop Redis Cluster instances."
echo "tail <id>   -- Run tail -f of instance at base port + ID."
echo "client <id>   -- Run client <INDEX_OF_PORT> to connect to it and issue commands"
    ;;

*)
    echo -e "\nPlease pass valid argument start/stop/status/tail/client"
    echo -e "\nHave below in your .bashrc to autocomplete possible values for this\n"
    echo -e '\e[0;34mcomplete -W "start stop status tail client" redis-cluster.sh\e[m'
    echo ""
;;

esac

exit $ERROR

