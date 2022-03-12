FROM nginx:1.19

RUN chmod -R a+rw /var/cache/nginx/
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html
RUN mkdir -p /etc/nginx/certs
COPY default_tls.key /etc/nginx/certs/tls.key
COPY default_tls.crt /etc/nginx/certs/tls.crt
RUN rm /etc/nginx/conf.d/default.conf
RUN chgrp -R 0 /etc/nginx && chmod -R g=u /etc/nginx

EXPOSE 8080 4443
CMD ["nginx", "-g", "daemon off;"]
