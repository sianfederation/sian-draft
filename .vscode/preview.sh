#!/usr/bin/env bash
# Local preview of the GitHub Pages site. See the Gemfile for background.
set -euo pipefail
cd "$(dirname "$0")/.."

RUBY33="$(brew --prefix ruby@3.3 2>/dev/null || true)"
if [ -z "$RUBY33" ] || [ ! -d "$RUBY33" ]; then
  echo "Ruby 3.3 is required: brew install ruby@3.3" >&2
  exit 1
fi
export PATH="$RUBY33/bin:$PATH"
export GEM_HOME="${GEM_HOME:-$HOME/.gem-pages-33}"
export PATH="$GEM_HOME/bin:$PATH"
export PAGES_REPO_NWO=sianfederation/sian-draft

command -v bundle >/dev/null || gem install bundler
bundle check >/dev/null 2>&1 || bundle install

echo "Preview at http://localhost:4000/sian/"
exec bundle exec jekyll serve --baseurl /sian --livereload
