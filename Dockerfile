FROM ubuntu:jammy

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y autoremove
RUN apt-get -y purge $(dpkg -l | grep '^rc' | awk '{print $2}')
RUN apt-get clean

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install munin-node python3 python3-pymongo

RUN rm -rf /etc/munin
RUN mkdir /etc/munin /etc/munin/plugin-conf.d /etc/munin/plugins
ADD munin-node.conf /etc/munin
ADD munin-node /etc/munin/plugin-conf.d

ADD docker-entrypoint.sh /root

RUN git clone https://github.com/munin-monitoring/contrib /opt/munin-contrib
RUN ln -sf \
	/opt/munin-contrib/plugins/mongodb/mongodb_conn \
	/opt/munin-contrib/plugins/mongodb/mongodb_docs \
	/opt/munin-contrib/plugins/mongodb/mongodb_multi \
	/etc/munin/plugins/

RUN git clone https://github.com/paulchen/mongomon /opt/mongomon
RUN (cd /opt/mongomon && git checkout count-per-database)
RUN ln -sf \
	/opt/mongomon/mongo_collcount \
	/opt/mongomon/mongo_collsize \ 
	/opt/mongomon/mongo_indexsize \
	/opt/mongomon/mongo_collcount_alldb \
	/opt/mongomon/mongo_collsize_alldb \
	/opt/mongomon/mongo_indexsize_alldb \
	/opt/mongomon/mongo_storagesize_alldb \
	/etc/munin/plugins/

CMD /root/docker-entrypoint.sh

