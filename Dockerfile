FROM  nginx

COPY  _site /usr/share/nginx/html

RUN   find /usr/share/nginx/html -type f -exec chmod 644 {} \;
RUN   find /usr/share/nginx/html -type d -exec chmod 755 {} \;
