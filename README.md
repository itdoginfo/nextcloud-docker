Nextcloud in docker with Nginx, Redis and Traefik 🐋

Traefik is used to automatically obtain/renew a TLS certificate and for redirect http to https

Based on an [official example](https://github.com/nextcloud/docker/tree/master/.examples/docker-compose/with-nginx-proxy/mariadb-cron-redis/fpm)

# How-to start

## Configuration
Replace all __change_me__ with your values

### db.env
- MYSQL_PASSWORD - nextcloud DB user password

### docker-compose.yml
- MYSQL_ROOT_PASSWORD - root password for MariaDB container

- ```test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost", "-u", "root", "-pchange_me"]```
Repeat MYSQL_ROOT_PASSWORD password. This is a database healthcheck. __"-pPass"__ for example

- ```      - "traefik.frontend.rule=Host:change_me"```
Your domain. __traefik.frontend.rule=Host:example.com__

### traefik/config/traefik.toml
- ```domain = "change_me"```
Yes, domain again

- ```email = "change_me"```
Your email

## Create external network
```
docker network create traefik
```

## Up
```
docker-compose up
```
or
```
docker-compose up -d
```

## Storage for data
By default, your data is stored in ./volumes/data

For example, you have a disk for your data and it is mounted to /mnt/storage

Replace with
```
      - ./volumes/data:/data
```
to
```
      - /mnt/storage:/data
```

# Issues
## ERROR: Network traefik declared as external, but could not be found. Please create the network manually using `docker network create traefik` and try again.

Just do what he asks
```
docker network create traefik
```

## time="2019-08-17T10:46:43Z" level=error msg="Failed to read new account, ACME data conversion is not available : permissions 755 for acme.json are too open, please use 600"
```
rm -rf traefik/config/acme.json
touch traefik/config/acme.json
chmod 600 traefik/config/acme.json
```

# Move MariaDB database to docker
## Backup
```
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on
sudo mysqldump --single-transaction -u nextcloud -p nextcloud > ~/nextcloud-dump.sql
```

## Restore
```
docker exec -it nextcloud-docker_db_1 mysql -h localhost -u root -pPass -e "DROP DATABASE nextcloud"
docker exec -it nextcloud-docker_db_1 mysql -h localhost -u root -pPass -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
cat ~/nextcloud-dump.sql | docker exec -i  nextcloud-docker_db_1 mysql -u root -pPass nextcloud
docker-compose down
docker-compose up -d
```

# Other
## permission-data.sh?
At the moment, docker-compose does not allow to set permissions on a directory.
When volume mounted, the directory inside the container gets root rights. For correct work are needed www-data user rights.

## Maintenance nextcloud in docker
```
docker exec -u www-data -it nextcloud-docker_app_1 php occ maintenance:mode --on
```

## Manual healthcheck Mariadb 
```
docker exec -it nextcloud-docker_db_1 mysqladmin ping -u root -p123
```
