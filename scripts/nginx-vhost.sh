#!/bin/bash

############################################################
#                                                          #
#                       Constants                          #
#                                                          #
############################################################

# Nginx config directory.
NGINX_CONF_PATH=/etc/nginx
### Unused ###
NGINX_SITES_ENABLED_PATH="$NGINX_CONF_PATH"/sites-enabled
NGINX_SITES_AVAILABLE_PATH="$NGINX_CONF_PATH"/sites-available
NGINX_VHOST_PATH=/etc/nginx/conf.d          #     Old constant.
### Unused ###
NGINX_CONFD_PATH="$NGINX_CONF_PATH"/conf.d
NGINX_DEFAULT_VHOST_PATH=/var/www

############################################################
#                                                          #
#                       Variables                          #
#                                                          #
############################################################

#
# First argument can be:
#     create - create new virtual host
#     delete - delete existing virtual host
#

# Command Line Arguments
#   -p path - Path of the VHost root
#   --disable-php-fpm - Disable php-fpm
#   -u user
#   -g group
#

if [[ "$#" -lt "2" ]];
then
  echo "Number of arguments is invalid"
  exit 0
fi

SCRIPT_NAME="$0"
COMMAND="$1"
VHOST_NAME="$2"
VHOST_ROOT="$NGINX_DEFAULT_VHOST_PATH/$VHOST_NAME"
ENABLE_PHP_FPM=true
VHOST_USER="root"
VHOST_GROUP="root"

shift 2

while [[ $# > 0 ]]; do
  key="$1"

  case $key in
  --disable-php-fpm)
    ENABLE_PHP_FPM=false
  ;;
  -p)
    VHOST_ROOT=$(echo "$2" | sed -e 's#/$##')/"$VHOST_NAME" # Strip trailing slashes.
    shift
  ;;
  -u)
    VHOST_USER="$2"
    VHOST_GROUP="$2"
    shift
  ;;
  -g)
    VHOST_GROUP="$2"
    shift
  ;;
  esac
  shift
done

############################################################
#                                                          #
#                         Pathes                           #
#                                                          #
############################################################

VHOST_HTML_PATH="$VHOST_ROOT"/public_html
VHOST_LOG_PATH="$VHOST_ROOT"/logs
VHOST_ACCESS_LOG_PATH="$VHOST_LOG_PATH"/access.nginx.log
VHOST_ERROR_LOG_PATH="$VHOST_LOG_PATH"/error.nginx.log
VHOST_CONFIG_PATH="$NGINX_CONFD_PATH/$VHOST_NAME.conf"


case $COMMAND in
  create)
    echo "Creating new Virtual Host: $VHOST_NAME"
    mkdir -p "$VHOST_LOG_PATH"
    mkdir -p "$VHOST_HTML_PATH"
    chown -R "$VHOST_USER:$VHOST_GROUP $VHOST_ROOT"
    echo "server {
      listen 80;
      root $VHOST_ROOT;

      access_log $VHOST_ACCESS_LOG_PATH;
      error_log $VHOST_ERROR_LOG_PATH;

      server_name $VHOST_NAME www.$VHOST_NAME;

      location / {
        index index.php index.html index.htm
      }
    }" >> "$VHOST_CONFIG_PATH"
  ;;
  delete)
    echo "Deleting existing virtual host. ### Not implemented yet ###"
  ;;
  *)
    echo "Invalid command"
  ;;
esac

#
#server {
#  listen 80;
#  root path_to_root;
#
#  access_log wtf;
#  error_log wtf;
#
#  server_name something www.something;
#  location / {
#    index index.php index.html index.htm
#  }
#  location ~ \.php$ {
#    fastcgi_pass unxi:/path_to_socket;
#    fastcgi_index index.php
#    factcgi_param SCRIPT_FILENAME $document_root$fastcgiscript_name;
#    include fastcgi_params;
#  }
#}
