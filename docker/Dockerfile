# Use this to build a docker container to run Bchan. This is recommended, as
# CGI scripts have high potential for security vulnerabilities, and I am not a
# perfect programmer. Docker doesn't provide perfect isolation, but it's better
# than nothing.

# This was written using https://github.com/rodolpheche/nginx-fcgiwrap-docker/
# as a reference, but nothing was copy/pasted and most of the nginx configs
# were changed.

FROM nginx:latest

# Install fcgiwrap and some things the scripts need like bc and uuid-gen
RUN apt-get update && apt-get install -y fcgiwrap bc uuid-runtime

COPY nginx /etc/nginx

VOLUME [ "/var/www" ]

CMD spawn-fcgi -s /var/run/fcgiwrap.socket /usr/sbin/fcgiwrap && nginx -g "daemon off;"
