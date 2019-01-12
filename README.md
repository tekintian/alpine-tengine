# Alpine Linux with Tengine docker images


## 默认路径

- 自定义主机配置文件夹

  /etc/nginx/conf.d/


- 默认主机配置文件路径  

  /etc/nginx/conf.d/default.conf

- nginx配置文件路径 

   /etc/nginx/nginx.conf


## 与mysql/mariadb数据库与PHP容器联合使用 示例：

~~~shell
# 数据库容器 https://hub.docker.com/r/library/mysql/
docker run --name mysql8 -it -d -p 3306:3306 -p 33060:33060 -v /home/data:/var/lib/mysql -v /LocalPath/conf.d:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=888888 -e character-set-server=utf8mb4 -e collation-server=utf8mb4_unicode_ci  mysql:8

# 使用本容器需要先启动数据库和PHP容器，否则无法使用数据库和PHP
docker run -it -d --name phpaf --link mysql8:db --volumes-from tengine tekintian/alpine-php:7.2

# tengine 容器
docker run --name tengine -it -d --link phpaf:php -v /Bitbucket/tools/Alpine/alpine-tengine:/var/www -v /home:/home -p 80:80 -p 443:443 tekintian/alpine-tengine

~~~




## 单独运行 Alpine Tengine 容器

```shell
# 如果需要单独运行本容器，需要使用自定义的 default.conf 配置文件覆盖容器默认的配置文件才能运行
docker run --name tengine -it -d  -v /localPath/default.conf:/etc/nginx/conf.d/default.conf -v /LocalApp:/var/www -p 80:80 -p 443:443 tekintian/alpine-tengine
```



当度运行 Tengine 容器示例 default.conf 文件

~~~conf
server {
    listen 80;
    server_name _;
    root /var/www/public;
    index index.html index.htm default.html;
#error page
    error_page 404             /404.html;
    error_page 500 502 503 504 /50x.html;

    #静态资源缓存配置
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ { expires 30d;  access_log off; }
    location ~ .*\.(js|css)?$ { expires 7d; access_log off; }
    location ~ /\.ht { deny all; }
  }

~~~



To reload the NGINX configuration, run this command:
#重新加载容器中的nginx配置文件 相当于 service nginx reload
docker kill -s HUP nginx

#重启nginx容器 【nginx为你的nginx容器的名称】
docker restart nginx


使用nginx自带参数 -s 停止nginx
/usr/local/nginx/sbin/nginx -s stop

重新加载配置
/usr/local/nginx/sbin/nginx -s reload


To reload the NGINX configuration, run this command:

docker kill -s HUP nginx

To restart NGINX, run this command to restart the container:

docker restart nginx




## Donate

![donate](donate.png)


