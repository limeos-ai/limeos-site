# limeos.ai on Railway: the static site, served by Caddy (rules in Caddyfile).
#
# The Caddyfile has to be in the build context, so a throwaway stage gathers the
# site and drops it there. The final image then takes the site in one copy and
# never deletes anything: a file removed in a later layer still turned up on
# Railway (the first deploy served /Caddyfile and /Dockerfile).
# .dockerignore keeps the Dockerfile, dotfiles and README out of the context.
FROM caddy:2.8.4-alpine AS site
COPY . /site
RUN rm -f /site/Caddyfile

FROM caddy:2.8.4-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=site /site /srv
