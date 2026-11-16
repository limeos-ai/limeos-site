# limeos.ai

The LimeOS site: static files, no build step, no dependencies.

- `index.html`: the homepage. It is self-contained (the font is inlined as woff2 and
  the mark is drawn on a canvas at runtime), so it makes **zero external requests**.
- `og.png`: the 1200x630 card shown when the link is pasted into Slack, iMessage, LinkedIn.
- `services/`: the five pages at limeos.ai/services, with `site.css` and `images/`.
- `customer-tracker/`: the customer tracker at limeos.ai/customer-tracker, and its
  working demo at `/customer-tracker/demo/`.
- `CNAME`: the domain. Pages used to read it; it now takes the domain from the repo's
  settings, so nothing reads this file.
- `.github/workflows/pages.yml`: publishes every push to `main` with GitHub Pages.
- `Caddyfile`, `Dockerfile`, `.dockerignore`, `.github/workflows/deploy.yml`: the same
  site on Railway, kept running as a standby.

## Hosting

**GitHub Pages serves limeos.ai** from this repo. Pages is free only while the repo is
public. To keep the site on Pages with the repo private, the `limeos-ai` account needs
GitHub Pro.

Railway runs the same site at https://limeos-site-production.up.railway.app. It's there
so the domain can move to Railway if the repo should go private without Pro:

- Railway project `limeos-site`, in the LimeOS Railway account, environment `production`.
- Service `limeos-site` has `limeos.ai` attached, waiting for the DNS records below.
- Service `www-redirect` holds `www.limeos.ai`, because the Hobby plan allows one
  custom domain per service. It runs the same image: the Caddyfile answers any
  `www.limeos.ai` request with a 301 to the same path on `https://limeos.ai`.

Both hosts serve the files the same way: `/services/how-it-works` answers with
`how-it-works.html`, `/services` redirects to `/services/`, and anything missing is a 404.
Neither publishes the build files or this README.

## Deploying

Push to `main`. Two workflows run:

- `pages.yml` publishes to GitHub Pages. The new version is live a minute or two later.
- `deploy.yml` runs `railway up` for the `limeos-site` service, so the standby stays
  current. `www-redirect` only needs a redeploy when the Caddyfile changes:
  Actions > Deploy to Railway > Run workflow > `www-redirect`.

The `RAILWAY_TOKEN` secret is a Railway project token. It can deploy this project and
nothing else.

## DNS (Namecheap, BasicDNS)

The records set now are for GitHub Pages:
- four A records on `@`: 185.199.108.153, 185.199.109.153, 185.199.110.153 and 185.199.111.153;
- a CNAME on `www` to a `github.io` name.

Every Pages site shares those addresses, and GitHub picks the site by the name that was
asked for. So the domain goes to whichever repo claims it in Settings > Pages. **Never
turn Pages off while the DNS still points at GitHub.** Until a site claims the domain,
any GitHub account can.

To move to Railway, change these records first. Then turn Pages off and make the repo
private.

| Type  | Host                  | Value |
|-------|-----------------------|-------|
| ALIAS | `@`                   | `ewct8ka6.up.railway.app`, in place of the four A records |
| CNAME | `www`                 | `vtn4cwo7.up.railway.app` |
| TXT   | `_railway-verify`     | `railway-verify=6d017de1e027801f2e98835955c8165ca5fdc6c1eee129fb20ca2be8cecb201a` |
| TXT   | `_railway-verify.www` | `railway-verify=a8c8e9f031cb370c1722259a75bae7ed1241673cff7e18036ad298014edd11ea` |

The two TXT records prove to Railway that we own the names. It won't route traffic or
issue certificates without them. The MX record (Google) and the SPF, Google and
Anthropic TXT records on `@` are for email and accounts: leave them alone.

## Editing

There is no toolchain: edit the HTML and push. If you change the homepage copy, change
the `og:description` and `twitter:description` meta tags too, or the link preview will
disagree with the page.

To preview locally with the same rules, run Caddy 2.8 from the repo root:
`PORT=8080 SITE_ROOT=. caddy run --config Caddyfile --adapter caddyfile`, then open
http://localhost:8080.
