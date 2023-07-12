Dockerfile

Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен 
отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).
Определите разницу между контейнером и образом.
Вывод опишите в домашнем задании.
Ответьте на вопрос: Можно ли в контейнере собрать ядро?

docker ps
docker ps -a
docker run -d -p port:port container_name
docker stop container_name
docker logs container_name - вывод логов контейнеров
docker inspect container_name - информация по запущенному контейнеру
docker build -t dockerhub_login/reponame:ver
docker push/pull
docker exec -it container_name bash

Что должно быть Dockerfile:
FROM image name
RUN apt update -y && apt upgrade -y
COPY или ADD filename /path/in/image
EXPOSE portopenning
CMD or ENTRYPOINT or both

1. Установим docker согласно официальной документации: https://docs.docker.com/engine/install/ubuntu/

```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

2. Соберём свой кастомный образ nginx на alpine, для этого напишем Dockerfile следующего содержания:

```
FROM alpine:latest
LABEL custom NGINX
RUN apk update && apk upgrade && apk add nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```
и в текущую директорию приложим наш кастомный index.html и nginx.conf

3. Разрешим текущему пользователю работать с докер и соберем образ:

```
sudo usermod -aG docker $USER

neva@Uneva:~/Otus_Kaneva_dz13$ docker build -t mynginx .
[+] Building 0.5s (9/9) FINISHED                                                                                                                                                                                              docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                    0.0s
 => => transferring dockerfile: 262B                                                                                                                                                                                                    0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                                                                         0.0s
 => [internal] load metadata for docker.io/library/alpine:latest                                                                                                                                                                        0.4s
 => [1/4] FROM docker.io/library/alpine:latest@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1                                                                                                                  0.0s
 => [internal] load build context                                                                                                                                                                                                       0.0s
 => => transferring context: 499B                                                                                                                                                                                                       0.0s
 => CACHED [2/4] RUN apk update && apk upgrade && apk add nginx                                                                                                                                                                         0.0s
 => [3/4] COPY nginx.conf /etc/nginx/nginx.conf                                                                                                                                                                                         0.0s
 => [4/4] COPY index.html /usr/local/nginx/html/index.html                                                                                                                                                                              0.0s
 => exporting to image                                                                                                                                                                                                                  0.0s
 => => exporting layers                                                                                                                                                                                                                 0.0s
 => => writing image sha256:4b4a568ffe9d1a7e6b58519c8de3a78e9ecf28bc92b7e5ee34aac8c12e7203d3                                                                                                                                            0.0s
 => => naming to docker.io/library/mynginx  
```

4. Проверяем, какие образы докера есть:

```
neva@Uneva:~/Otus_Kaneva_dz13$ docker images -a
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
mynginx      latest    4b4a568ffe9d   2 minutes ago   11.5MB
<none>       <none>    021283c8eb95   6 days ago      187MB
```

5. Запустим контейнер из образа mynginx, прибиндив порт 8080 локальной машины:

```
neva@Uneva:~/Otus_Kaneva_dz13$ docker run -p8080:8080 --name mynginx -dt mynginx
```

6. Проверим, что контейнер запутился и работает:

```
neva@Uneva:~/Otus_Kaneva_dz13$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                       NAMES
e29247741d08   mynginx        "nginx -g 'daemon of…"   4 seconds ago   Up 3 seconds   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   mynginx
7bc0cf28cbe6   021283c8eb95   "/docker-entrypoint.…"   3 days ago      Up 3 days      80/tcp  
```

7. Узнаем ip адрес контейнера:

```
neva@Uneva:~/Otus_Kaneva_dz13$ docker inspect mynginx | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.3",
                    "IPAddress": "172.17.0.3",
```

8. Пробуем подключиться на адрес и порт nginx в контейнере

```
neva@Uneva:~/Otus_Kaneva_dz13$ curl 172.17.0.3:8080
<!nginx html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>HTML5</title>
</head>
<body>
    Hello, it's me, your nginx from docker!
</body>
</html>
```

Ура, видим наш кастомный index.html

9. Регистрируемся на https://hub.docker.com, создаём там свой публичный репозиторий, присваем образу тэг и пушаем его.

```
neva@Uneva:~$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: zoyqqyoz
Password:
WARNING! Your password will be stored unencrypted in /home/neva/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

neva@Uneva:~/Otus_Kaneva_dz13$ docker tag mynginx zoyqqyoz/otuz_kaneva_dz13:v1.0
neva@Uneva:~/Otus_Kaneva_dz13$ docker push zoyqqyoz/otuz_kaneva_dz13:v1.0
The push refers to repository [docker.io/zoyqqyoz/otuz_kaneva_dz13]
2e97f53fa47a: Pushed
371282295e15: Pushed
34d5d62416ca: Pushed
78a822fe2a2d: Pushed
v1.0: digest: sha256:d3eeaf6f49c5f1611e704115e8ed39e4e7279e395123e324242a9c9a3a0e5d81 size: 1154
```

10. Вот ссылка на репозиторий: 

```
https://hub.docker.com/repository/docker/zoyqqyoz/otuz_kaneva_dz13/general
```

11.  Определите разницу между контейнером и образом:

```
Образ Docker (Docker Image) - это неизменяемый файл, содержащий исходный код, библиотеки, зависимости, инструменты и другие файлы, необходимые для запуска приложения.
Образ представляет приложение и его виртуальную среду в определенный момент времени.
Образ - это шаблон, на основе которого создается контейнер, существует отдельно и не может быть изменен. 
Контейнер Docker (Docker Container) - это виртуализированная среда выполнения, созданная на основе образа. При запуске контейнерной среды внутри контейнера создается копия файловой системы (docker образа) для чтения и записи. 
```

12. Можно ли в контейнере собрать ядро?

```
Собрать можно, но загрузиться с него нельзя.
```







