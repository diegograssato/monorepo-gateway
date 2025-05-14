#!/bin/sh

TEMPLATE_FILE="/etc/nginx/nginx.conf.template"
OUTPUT_FILE="/etc/nginx/nginx.conf"
HTML_TEMPLATE="/usr/share/nginx/html/index.html.template"
HTML_OUTPUT="/usr/share/nginx/html/index.html"

LOCATIONS=""
LINKS=""
# Separando os serviços com set --
IFS=','; set -- $SERVICES
for entry in "$@"; do
    # NAME=$(echo "$entry" | cut -d':' -f1)
    # PORT=$(echo "$entry" | cut -d':' -f2)
    # ENABLED=$(echo "$entry" | cut -d':' -f3)
    # PATH=$(echo "$entry" | cut -d':' -f4)

    OLDIFS="$IFS"
    IFS=':'; set -- $entry
    NAME=$1
    PORT=$2
    ENABLED=$3
    LOCATION=$4
    IFS="$OLDIFS"
    
    # Verifica se o serviço está habilitado
    if [ -z "$NAME" ] || [ -z "$PORT" ]; then   
        echo "Invalid service entry: $entry"
        continue
    fi
    # Defaults
    [ -z "$ENABLED" ] && ENABLED="no"
    [ -z "$PORT" ] && PORT="80"  # Default para 80 se não for passado
    [ -z "$LOCATION" ] && LOCATION="/$NAME/"  # Default para o nome do serviço se não for passado
    # Garante que o LOCATION tenha barras corretas
    LOCATION="/$(echo "$LOCATION" | sed 's|^/*||;s|/*$||')/"
    echo "Processing service: $NAME with port: $PORT, enabled: $ENABLED, location: $LOCATION"


    ICON="🔗";
    # Verifica se o serviço está habilitado
    if [ "$ENABLED" = "yes" ]; then
        LOCATIONS="$LOCATIONS
        location $LOCATION {
            proxy_pass http://$NAME:$PORT/;
            include /etc/nginx/includes/proxy-headers.conf;
            opentracing_tag "nginx-location" "$LOCATION";
            opentracing_propagate_context;
            proxy_connect_timeout 1s;
            proxy_read_timeout 1s;
            error_page 502 = /fallback;
        
        }"
        NAME_CAP=$(echo "$NAME" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
        LINKS="$LINKS<li><a href=\"http://localhost:8080$LOCATION\">$ICON $NAME_CAP</a></li>"
    else
        
        LOCATIONS="$LOCATIONS
        location $LOCATION {
            default_type text/plain;
            return 404 'Service $NAME unavailable';
            opentracing_tag "nginx-location" "$LOCATION";
            include /etc/nginx/includes/proxy-headers.conf;
            add_header Content-Type text/plain;
            add_header X-Error-Message 'Service $NAME unavailable'; 
        }"
    fi
done

# Substitui a variável LOCATIONS no template usando envsubst
export LOCATIONS
envsubst '${LOCATIONS}' < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
# Exporta e substitui marcador no HTML
export LINKS
envsubst '${LINKS}' < "$HTML_TEMPLATE" > "$HTML_OUTPUT"
# Inicia o nginx
exec nginx -g "daemon off;"