# docker-munin-mongodb

Docker image for providing [MongoDB](https://www.mongodb.com/) statistics to [Munin](https://munin-monitoring.org/) via a `munin-node` instance.

## What's inside

* Ubuntu 21.04 "Hirsute Hippo" (base image)
* Munin plugins from various sources
* Enabled plugins:
  * From [munin-monitoring/contrib](https://github.com/munin-monitoring/contrib):
    * [mongodb_conn](https://github.com/munin-monitoring/contrib/blob/master/plugins/mongodb/mongodb_conn)
    * [mongodb_docs](https://github.com/munin-monitoring/contrib/blob/master/plugins/mongodb/mongodb_docs) 
    * [mongodb_multi](https://github.com/munin-monitoring/contrib/blob/master/plugins/mongodb/mongodb_multi) 
  * From [paulchen/mongomon](https://github.com/paulchen/mongomon):
    * [mongo_collcount](https://github.com/paulchen/mongomon/blob/master/mongo_collcount)
    * [mongo_collcount_alldb](https://github.com/paulchen/mongomon/blob/master/mongo_collcount_alldb)
    * [mongo_collsize](https://github.com/paulchen/mongomon/blob/master/mongo_collsize)
    * [mongo_collsize_alldb](https://github.com/paulchen/mongomon/blob/master/mongo_collsize_alldb)
    * [mongo_indexsize](https://github.com/paulchen/mongomon/blob/master/mongo_indexsize)
    * [mongo_indexsize_alldb](https://github.com/paulchen/mongomon/blob/master/mongo_indexsize_alldb)
    * [mongo_storagesize_alldb](https://github.com/paulchen/mongomon/blob/master/mongo_storagesize_alldb)
  * More plugins might follow in the future.

## How to build

```
git clone https://github.com/paulchen/docker-munin-mongodb.git
docker build docker-munin-mongodb -t docker-munin-mongodb
```

## Connectivity

* Connects to an instance of MongoDB at `localhost:27017`.
* Runs `munin-node` at port `4949`.

## How to run

When running the image, make sure to connect port `27017` to your running MongoDB and to expose port `4949`.

As this image was created having instances of MongoDB and [Rocket.Chat](https://rocket.chat/) in mind that are run via Docker
(see <https://docs.rocket.chat/installing-and-updating/docker-containers/systemd>), the command to run the image might look like this (which will wire port `4949` from the image to port `4950` on the host):

`docker run --name docker-munin-mongodb --link mongo:mongo --net=rocketchat_default -p 127.0.0.1:4950:4949 -p [::1]:4950:4949 docker-munin-mongodb:latest`

A complete systemd unit file might look like this:

```
[Unit]
Description=docker-munin-mongodb
Requires=docker.service
Requires=mongo.service
After=docker.service
After=mongo.service

[Service]
EnvironmentFile=/etc/environment
User=root
Restart=always
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop docker-munin-mongodb
ExecStartPre=-/usr/bin/docker rm docker-munin-mongodb

ExecStart=/usr/bin/docker run \
    --name docker-munin-mongodb \
    --link mongo:mongo \
    --net=rocketchat_default \
    -p 127.0.0.1:4950:4949 \
    -p [::1]:4950:4949 \
    docker-munin-mongodb:latest

ExecStop=-/usr/bin/docker stop docker-munin-mongodb
ExecStop=-/usr/bin/docker rm docker-munin-mongodb

[Install]
WantedBy=multi-user.target
```

Both the above `docker run` command and the systemd unit will wire the image's port `4949` to `localhost:4950`.
Configure a new host in your instance of Munin that connects to that port.

