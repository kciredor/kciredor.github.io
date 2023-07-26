# kciredor.com blog repository.

## Usage:
- Install: `bundle install`
- Author:  `bundle exec jekyll serve`
- Build:   `JEKYLL_ENV=production bundle exec jekyll build`
- Save:    git commit + push
- Publish:
  - `docker build -t eu.gcr.io/shining-domain-219614/kciredor-com --platform linux/amd64 .`
  - Push and cycle pods, see deploy.yaml.
