# redis-cluster-localdev
 This shell script would start n redis instances and make them join into cluster.
 
NOTE: This script is intended for local development use(to avoid redis installation) and not for any server use. Please do not use for any production.

Usage:
  Please pass valid argument start/stop/status/tail/client
  
## Command to start instances and make them into cluster:

  ./redis-cluster.sh start

## Command to stop cluster and it's instances:

  ./redis-cluster.sh stop
  
## Command to check status of docker instances:

./redis-cluster.sh status

```
  Status of Redis Cluster...

  CONTAINER ID   IMAGE         COMMAND                  CREATED             STATUS             PORTS     NAMES
  4e44aadc6a21   redis:5.0.6   "docker-entrypoint.s…"   About an hour ago   Up About an hour             redis-7003
  077ac51596d0   redis:5.0.6   "docker-entrypoint.s…"   About an hour ago   Up About an hour             redis-7002
  53d35cbfabe0   redis:5.0.6   "docker-entrypoint.s…"   About an hour ago   Up About an hour             redis-7001
```
 
## Command to tail logs of docker instances:

./redis-cluster.sh tail

```
  Please select one of node port 7001 7002 7003  [ENTER]: 7001
  docker logs --follow redis-7001
  1:C 16 Jan 2021 16:22:13.508 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
  1:C 16 Jan 2021 16:22:13.508 # Redis version=5.0.6, bits=64, commit=00000000, modified=0, pid=1, just started
  1:C 16 Jan 2021 16:22:13.508 # Configuration loaded
  1:M 16 Jan 2021 16:22:13.509 * No cluster configuration found, I'm dc22e8e6eb6ba50bbce1d4a524b161f5cc907e88
  1:M 16 Jan 2021 16:22:13.512 * Running mode=cluster, port=7001.
  1:M 16 Jan 2021 16:22:13.512 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
  1:M 16 Jan 2021 16:22:13.512 # Server initialized
  1:M 16 Jan 2021 16:22:13.512 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
  1:M 16 Jan 2021 16:22:13.512 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
  1:M 16 Jan 2021 16:22:13.512 * Ready to accept connections
  1:M 16 Jan 2021 16:22:14.331 # configEpoch set to 1 via CLUSTER SET-CONFIG-EPOCH
  1:M 16 Jan 2021 16:22:14.377 # IP address for this node updated to 127.0.0.1
  1:M 16 Jan 2021 16:22:15.518 # Cluster state changed: ok
```
## Command to connect to specific redis instance and issue commands:

./redis-cluster.sh client 2

```
  Connecting to Redis Cluster...
  docker run -it --rm --net host redis:5.0.6 redis-cli -c -h 127.0.0.1 -p 7002
  127.0.0.1:7002> 
```

./redis-cluster.sh client

```
Connecting to Redis Cluster...
Please select one of node port 7001 7002 7003  [ENTER]: 7003
docker run -it --rm --net host redis:5.0.6 redis-cli -c -h 127.0.0.1 -p 7003
127.0.0.1:7003> 
```


