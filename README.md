# Alpine Linux with Tengine docker images





## 与mysql/mariadb数据库与PHP容器联合使用 示例：

~~~shell
# 数据库容器 https://hub.docker.com/r/library/mysql/
docker run --name mysql8 -it -d -p 3306:3306 -p 33060:33060 -v /home/data:/var/lib/mysql -v /LocalPath/conf.d:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=888888 -e character-set-server=utf8mb4 -e collation-server=utf8mb4_unicode_ci  mysql:8

# 使用本容器需要先启动数据库和PHP容器，否则无法使用数据库和PHP
docker run -it -d --name phpaf --link mysql8:db -v /localpath:/var/www -v /LocalAppPath:/home/wwwroot tekintian/alpine-php:7.2

# tengine 容器
docker run --name tengine -it -d --link phpaf:php -v /Bitbucket/tools/Alpine/alpine-tengine:/var/www -v /home:/home -p 80:80 -p 443:443 tekintian/alpine-tengine

~~~










## Donate

![donate](donate.png)


