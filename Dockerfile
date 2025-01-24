FROM ubuntu:oracular

RUN apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y autoremove && \
	apt-get -y purge $(dpkg -l | grep '^rc' | awk '{print $2}') && \
	apt-get clean && \
	\
	DEBIAN_FRONTEND=noninteractive apt-get -y install munin-node python3 python3-pymongo monitoring-plugins-basic psmisc && \
	\
	rm -rf /etc/munin && \
	mkdir /etc/munin /etc/munin/plugin-conf.d /etc/munin/plugins && \
	\
	git clone https://github.com/munin-monitoring/contrib /opt/munin-contrib && \
	ln -sf \
		/opt/munin-contrib/plugins/mongodb/mongodb_conn \
		/opt/munin-contrib/plugins/mongodb/mongodb_docs \
		/opt/munin-contrib/plugins/mongodb/mongodb_multi \
		/etc/munin/plugins/ && \
	\
	git clone https://github.com/paulchen/mongomon /opt/mongomon && \
	cd /opt/mongomon && \
	git checkout count-per-database && \
	ln -sf \
		/opt/mongomon/mongo_collcount \
		/opt/mongomon/mongo_collsize \
		/opt/mongomon/mongo_indexsize \
		/opt/mongomon/mongo_collcount_alldb \
		/opt/mongomon/mongo_collsize_alldb \
		/opt/mongomon/mongo_indexsize_alldb \
		/opt/mongomon/mongo_storagesize_alldb \
		/etc/munin/plugins/

ADD munin-node.conf /etc/munin
ADD munin-node /etc/munin/plugin-conf.d

ADD docker-entrypoint.sh /root

HEALTHCHECK --interval=5m --timeout=10s CMD /usr/lib/nagios/plugins/check_tcp -H localhost -p 4949 || exit 1

CMD [ "/root/docker-entrypoint.sh" ]

