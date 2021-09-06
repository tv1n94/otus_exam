Ссылка на wiki контейрера - https://github.com/bitnami/bitnami-docker-pgbouncer

Перед тестовым запуском надо создать каталог /pgbouncer и добавит туда файлы из каталога conf
`mkdir /pgbuncer`
`chown -R 1001:1001 /pgbouncer`

Команда запуска Docker-контейнера без Nomad Job:
`docker run -d --net=host -e POSTGRESQL_PASSWORD=postgres -e POSTGRESQL_HOST=192.168.2.11 -e POSTGRESQL_PORT=5432 -v /pgbouncer/:/bitnami/pgbouncer/conf/ bitnami/pgbouncer:latest`

Доступ к БД через контейнер pgbouncer `psql -h 127.0.0.1 -p 6432`