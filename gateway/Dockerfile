FROM opentracing/nginx-opentracing

COPY jaeger-config.json /etc/jaeger-config.json
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY index.html.template /usr/share/nginx/html/index.html.template
COPY proxy-headers.conf /etc/nginx/includes/proxy-headers.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
