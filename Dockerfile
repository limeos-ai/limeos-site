# limeos.ai on Railway: the static site, served by Caddy (rules in Caddyfile).
FROM caddy:2.8.4-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY . /srv
RUN rm -f /srv/Dockerfile /srv/Caddyfile /srv/.dockerignore
