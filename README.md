# druidfi/symfony-minor-pin

A Composer metapackage that keeps every Symfony component on one minor version line (e.g. `6.4`, `7.2`, `8.1`), without relying on Symfony Flex.

## Why

Symfony Flex keeps components on one version line with `extra.symfony.require` (e.g. `"7.2.*"`). That only works when the Flex plugin runs. Tools such as [Renovate](https://docs.renovatebot.com/) run Composer with `--no-plugins`, so indirect dependencies (e.g. `symfony/http-foundation` required by `symfony/framework-bundle`) can be updated to a newer minor or major version.

This package declares a `conflict` with the next minor version for every Symfony component. It has no code and no dependencies, so it installs nothing and only blocks versions outside the pinned line.

## Usage

Require the same line as `extra.symfony.require`:

```bash
composer require druidfi/symfony-minor-pin:7.2.*
```

| Version | Keeps components on | Conflicts with |
|---------|---------------------|----------------|
| `6.4.*` | Symfony 6.4         | `>=7.0`        |
| `7.0.*` | Symfony 7.0         | `>=7.1`        |
| `7.1.*` | Symfony 7.1         | `>=7.2`        |
| `7.2.*` | Symfony 7.2         | `>=7.3`        |
| `7.3.*` | Symfony 7.3         | `>=7.4`        |
| `7.4.*` | Symfony 7.4         | `>=8.0`        |
| `8.0.*` | Symfony 8.0         | `>=8.1`        |
| `8.1.*` | Symfony 8.1         | `>=8.2`        |

When upgrading Symfony, change this requirement together with `extra.symfony.require`.

## Adding a new minor version

Each minor has its own branch (e.g. `8.1`) and tag (e.g. `8.1.0`). Once a new Symfony minor has a stable release:

```bash
git checkout -b 8.2 main
./generate.sh 8.2
git commit -am "Symfony 8.2" && git tag 8.2.0
git push origin 8.2 8.2.0
```

Then fast-forward `main` to the newest minor.

`generate.sh` lists every package in the [symfony/symfony](https://github.com/symfony/symfony) monorepo at the latest patch release of the minor (contracts packages are excluded, they are versioned separately).

## License

MIT
