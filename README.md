# limeos.ai

The LimeOS site: static files, no build step, no dependencies.

- `index.html`: the homepage. It is self-contained (the font is inlined as woff2 and
  the mark is drawn on a canvas at runtime), so it makes **zero external requests**.
- `og.png`: the 1200x630 card shown when the link is pasted into Slack, iMessage, LinkedIn.
- `services/`: the five pages at limeos.ai/services, with `site.css` and `images/`.
- `customer-tracker/`: the customer tracker at limeos.ai/customer-tracker, and its
  working demo at `/customer-tracker/demo/`.
- `CNAME`: left over from GitHub Pages hosting. Nothing reads it now.
- `Caddyfile`, `Dockerfile`, `.dockerignore`: how Railway serves the site.
- `.github/workflows/deploy.yml`: deploys every push to `main`.

## Hosting

Railway project `limeos-site` (the LimeOS Railway account, environment `production`):

- Service `limeos-site` serves the site at https://limeos.ai, and at
  https://limeos-site-production.up.railway.app.
- Service `www-redirect` holds `www.limeos.ai`, because the Hobby plan allows one
  custom domain per service. It runs the same image: the Caddyfile answers any
  `www.limeos.ai` request with a 301 to the same path on `https://limeos.ai`.

Caddy serves the files the way GitHub Pages did: `/services/how-it-works` answers with
`how-it-works.html`, `/services` redirects to `/services/`, and anything missing is a 404.
Railway handles HTTPS.

## Deploying

Push to `main`. The workflow runs `railway up` for the `limeos-site` service, Railway
builds the Dockerfile, and the new version is live about a minute later.

`www-redirect` only needs a redeploy when the Caddyfile changes:
Actions > Deploy to Railway > Run workflow > `www-redirect`.

The workflow's `RAILWAY_TOKEN` secret is a Railway project token. It can deploy this
project and nothing else.

## DNS (Namecheap, BasicDNS)

| Type  | Host                  | Value |
|-------|-----------------------|-------|
| ALIAS | `@`                   | `ewct8ka6.up.railway.app` |
| CNAME | `www`                 | `vtn4cwo7.up.railway.app` |
| TXT   | `_railway-verify`     | `railway-verify=6d017de1e027801f2e98835955c8165ca5fdc6c1eee129fb20ca2be8cecb201a` |
| TXT   | `_railway-verify.www` | `railway-verify=a8c8e9f031cb370c1722259a75bae7ed1241673cff7e18036ad298014edd11ea` |

The two TXT records prove to Railway that we own the names; it won't route traffic or
issue certificates without them. The MX record (Google) and the SPF, Google and
Anthropic TXT records on `@` are for email and accounts: leave them alone.

## Editing

There is no toolchain: edit the HTML and push. If you change the homepage copy, change
the `og:description` and `twitter:description` meta tags too, or the link preview will
disagree with the page.

To preview locally with the same rules, run Caddy 2.8 from the repo root:
`PORT=8080 SITE_ROOT=. caddy run --config Caddyfile --adapter caddyfile`, then open
http://localhost:8080.
