FROM postgres:13 

RUN apt-get update -y\ 
    && apt-get install python3 python3-pip procps less vim net-tools traceroute iputils-ping -y\
    && python3 -m pip install --upgrade pip\
    && pip3 install psycopg2-binary \
    && pip3 install patroni[consul] \
    && mkdir /data/patroni -p \
    && chown postgres:postgres /data/patroni \
    && chmod 700 /data/patroni  

COPY patroni.yml /etc/patroni.yml
COPY patroni-entrypoint.sh ./entrypoint.sh

EXPOSE 5432
EXPOSE 8008

VOLUME ["/data/patroni","/var/log/postgresql"]

USER postgres

ENTRYPOINT ["bin/sh", "/entrypoint.sh"]