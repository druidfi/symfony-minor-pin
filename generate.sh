#!/bin/sh
# Generates composer.json for druidfi/symfony-minor-pin <minor>.0
#
# Usage: ./generate.sh 7.2
#
# Lists every package in the symfony/symfony monorepo at the latest patch
# release of <minor> (contracts excluded, they are versioned separately) and
# declares a conflict with the next minor: x.4 -> (x+1).0, otherwise x.(y+1).
# Requires curl and jq.
set -eu

minor="${1:?usage: $0 <minor>, e.g. 7.2}"
major="${minor%.*}"
m="${minor#*.}"
if [ "$m" = 4 ]; then next="$((major + 1)).0"; else next="$major.$((m + 1))"; fi

tag=$(curl -fsS https://repo.packagist.org/p2/symfony/symfony.json |
  jq -r --arg p "v$minor." '[.packages["symfony/symfony"][].version | select(startswith($p) and test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))] | first // empty')
[ -n "$tag" ] || { echo "No stable symfony/symfony release found for $minor" >&2; exit 1; }
echo "Using symfony/symfony $tag, conflicting with >=$next" >&2

curl -fsS "https://api.github.com/repos/symfony/symfony/git/trees/$tag?recursive=1" |
  jq -r '.tree[].path | select(test("^src/Symfony/.*/composer\\.json$")) | select(test("/(Tests|Resources|vendor)/") | not)' |
  xargs -P 16 -I{} curl -fsS "https://raw.githubusercontent.com/symfony/symfony/$tag/{}" |
  jq -r '.name // empty' |
  grep -v -e '-contracts$' -e '^symfony/contracts$' |
  sort -u |
  jq -R . | jq -s --arg minor "$minor" --arg next "$next" --arg tag "$tag" '{
    name: "druidfi/symfony-minor-pin",
    description: ("Keeps every Symfony component on the " + $minor + " line without Symfony Flex (e.g. for Renovate, which runs Composer without plugins). Installs nothing; only declares conflicts."),
    type: "metapackage",
    license: "MIT",
    keywords: ["symfony", "flex", "renovate", "version", "pin"],
    conflict: (map({key: ., value: (">=" + $next)}) | from_entries)
  }' > composer.json

echo "Wrote composer.json: $(jq '.conflict | length' composer.json) packages conflict with >=$next ($tag)" >&2
