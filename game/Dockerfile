FROM nginx:1.19

RUN chmod -R a+rw /var/cache/nginx/
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY export /usr/share/nginx/html/s3e
RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
