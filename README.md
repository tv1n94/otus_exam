OTUS-exam
![Image alt](https://github.com/tv1n94/otus_exam/blob/master/otus_exam.jpg)

Данная конфигурация позволяет развернуть комплекс из 7 виртуальных машин на Ubuntu 20 в провайдере Advanced Hosting (AH):

В комплексе использованы следующие технологии:
- Consul и Nomad кластера, для управления Docker-контейнерами
- Кластер БД с PostgreSQL, Patroni, PgBouncer
- ELK stack для хранения Docker-логов
- Prometheus для мониторинга состояния контейнеров на работающих хостах
- Nextcloud
- Резервное копирование БД и файлов с помощью tar и pg_dumpall
- Балансировщик нагрузки NGINX
- IPtables для запрета остального трафика

**Комплекс продолжит работать, если будет отказ одной ноды с БД (nomad1 или nomad2) и/или отказ одной ноды Nomad-сервера (Например Nomad-server1)**

Настройка будет происходить через Ansible. 

Виртуальные машины будут развёрнуты с адресами из подсети 192.168.2.0/24:
- nomad1        - 192.168.2.11
- nomad2        - 192.168.2.12
- nomad3        - 192.168.2.13
- nomad-server1 - 192.168.2.21
- nomad-server2 - 192.168.2.22
- nomad-server3 - 192.168.2.23
- Backup1       - 192.168.2.30

**Требования для запуска данной конфигурации:** 
-Наличие Linux-машины (Или Unix)
-Установленные пакеты Git, Ansible и Terraform.
-Аккаунт в Advanced Hosting, c добавленым токеном и ssh fingerprint. 
-В аккаунте AH не должно быть заведено подсети 192.168.2.0/24. 


**Описание terraform-файлов:**
-ansible.cfg - файл с конфигурацией Ansible

-main.tf - главный файл для terraform. Указываем наш провайдер и токен для работы с провайдером. 

-variables.tf - описание типов всех переменных

-vm.tf - файл, с описанием ВМ

-terraform.tfvars - файл, в котором хранятся все значения переменных. НУЖНО ЗАПОЛНИТЬ ПЕРЕД запуском команды terraform apply

-template.tf - сценарий, в котором содержится инструкция по выводу всех адресов в файл hosts

-output.tf - terraform-сценарий, который выводит нам IP-адрес созданной виртуальной машины

-provision.yml - Ansible-playbook для установки для развертывания кластера, ISCSI и GFS2.

-inventory.tpl - указываем формат файла hosts


**Как развернуть конфигурацию:** 
1) На подготовленную Linux-машину клонируем данный репозиторий `git clone https://github.com/tv1n94/otus_exam.git`
2) Открываем файл terraform.tfvars и вносим следующие значения параметров:

  -ah_dc - можно указать значение ams1 (Дата-центр в Амстердаме) или ash1 (Дата-центр в Америке)

  -ah_token - указываем значение из AH - API - Manage API access tokens

3) В файле vm.tf в разделе указываем ssh_key fingerprint вашего ключа из AH - SSH KEYS

4) Находясь в каталоге, выполняем команду `terraform plan` Данная команда поможет проверить, не было ли допущено ошибок

5) Выполняем команду `terraform apply --auto-approve`


**Проверка корректного выполнения скрипта:**
1) Вводим в адресной строке адрес Nextcloud
2) Откроется окно первоначальной настройки nextcloud. Вводим следующие данные:
- Имя пользователя и пароль
- Выбираем БД `PostgreSQL`
- Имя базы данных - `nextcloud`
- Имя пользователя БД - `nextcloud`
- Пароль пользователя БД - `nextcloud`
- `localhost:6432`

После первоначальной настройки необходимо настроить Trusted Domains, для этого, с хоста nomad1 вводим команду

`docker exec --user www-data $(docker ps | grep nextcloud | awk '{print $1}')  php occ config:system:set trusted_domains 1 --value=*`

3) После настройки можно будет пользоваться Nextcloud


4) Смотрим в файле hosts адрес Consul-сервера `cat hosts` находим адрес nomad-server1:8500
5) Вводим в адресной строке адрес Consul-серера смотрим состояние контейнеров

6) Можем остановить один из контейнеров, например `nomad stop nextcloud2` 
7) Смотрим файл hosts `cat hosts` находим адрес nomad3:8500
8) Вводим в адресной строке адрес Prometheus-серера смотрим состояние заданий, одно из них долно стать красным


**Удаление всего стенда с конфигурацией:**

Для удаления ВМ достаточно ввести команду: `terraform destroy --auto-approve`





**Дополнительная информация**
Веб-интерфейс Consul - `<IP nomad-server1>:8500`

Веб-интерфейс Prometheus - `<IP nomad3>:9999`

Веб-интерфейс Kiabna - `<IP nomad3>:5601`

В Kibanа нужно добавить Index pattern, тогда можно будет увидеть логи Docker-контейнеров

Доступ к БД:
Ноды db1 или db2: 
`sudo su - postgres`
`psql -p 5433 -h /var/data/base/`

Служба Postgresql будет отключена, так как она управляется Patroni
node1: 
`sudo su - postgres`
`psql -h localhost`

Для управления Nextcloud через CLI напишите: `docker exec --user www-data CONTAINER_ID php occ`


Проверка тома GlusterFS

Проверка состояния тома: `gluster volume status otus`

Вывод информации о томе: `gluster volume info otus`