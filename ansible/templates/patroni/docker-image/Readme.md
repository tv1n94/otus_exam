*Docker image was created for learning this article - https://habr.com/ru/company/vsrobotics/blog/534828/*

Base image - postgres:13

Example start container `docker run -d -p 5433:5432 -p 8008:8091 -v /patroni1:/data/patroni -e PATRONI_API_CONNECT_PORT=8091 -e REPLICATION_NAME=replicator -e REPLICATION_PASS=replpass -e SU_NAME=postgres -e SU_PASS=supass -e POSTGRES_APP_ROLE_PASS=appass -e PATRONI_CONSUL_URL=http://192.168.2.23:8500 tv1n94/patroni-otus`

*The container will not start normally without parameters.*

**Available volumes**

`/data/patroni` - most famous data of patroni (DBs and config files)

`/var/log/postgresql` - postgres logs


For create volume in linux use these commands:

`sudo mkdir /patroni1`

`sudo chown 999:999 /patroni1`

`sudo chmod 700 /patroni1`


*999 - default postgres user*


**Parameters:** 

`PATRONI_API_CONNECT_PORT` - port for Patroni RestAPI 

`REPLICATION_NAME` - replicator username

`REPLICATION_PASS` - replication password

`SU_NAME` - postgres user

`SU_PASS` - postgres user password

`POSTGRES_APP_ROLE_PASS` - password for postgres app role 

`PATRONI_CONSUL_URL` - URL for connection to Consul




Access to DB in container: `psql -h /data/patroni`

Check node in cluster: `patronictl -c /etc/patroni.yml list`