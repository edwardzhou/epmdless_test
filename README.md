# EpmdlessTest

**TODO: Add description**

The demostration for how to cluster dockerized elixir nodes on seperate hosts.


## build image

```bash
./build_image.sh
```

## run

### node 1
```bash
# start container
docker run --rm -it -p 17012:17012 -e HOST_IP=192.168.4.105 -e APP_NAME=a -e EPMDLESS_DIST_PORT=17012 -e NODE_LIST=a@192.168.4.105:17012,b@192.168.4.105:17013  epmdless_test:1.0

```

### node 2
```bash
# start container
docker run --rm -it -p 17013:17013 -e HOST_IP=192.168.4.105 -e APP_NAME=b -e EPMDLESS_DIST_PORT=17013 -e NODE_LIST=a@192.168.4.105:17012,b@192.168.4.105:17013  epmdless_test:1.0

> Node.list()
# the node1 shows up

```




#### Environment descrition

| variable | description |
| -------- | ---------------------------------------------------- |
| HOST_IP  | container's host ip, for outside connect to          |
| APP_NAME | the first part of node name.  \$\{APP_NAME}@\$\{HOST_IP}. eg a@192.168.4.105 |
| EPMDLESS_DIST_PORT | the epmd listening port |
| NODE_LIST | the list of nodes for cluster, seperated wity comma |



for HOST_IP and APP_NAME, reference to rel/env.sh.eex

EPMDLESS_DIST_PORT and NODE_LIST, reference to config/runtime.exs
