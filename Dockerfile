FROM alpine:latest
LABEL custom NGINX
RUN apk update && apk upgrade && apk add nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]




