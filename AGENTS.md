# AGENTS.md

## Releases & Changelog

Releases are automated with [release-please](https://github.com/googleapis/release-please). **Do not edit `CHANGELOG.md`, the `version` in `pubspec.yaml` or `.release-please-manifest.json` by hand.**

Pull requests are squash-merged, so the **pull request title** must be a [Conventional Commit](https://www.conventionalcommits.org). It becomes the changelog entry and decides the version bump:

| PR title | Release |
|----------|---------|
| `fix: ...` | patch (0.0.x) |
| `feat: ...` | minor (0.x.0) |
| `feat!: ...` | major (x.0.0) |
| `docs:`, `ci:`, `chore:`, `refactor:`, `test:` | no release on their own |

How a release happens:

1. Every push to `main` runs `.github/workflows/release.yml`. release-please keeps one open **release PR** (`chore(main): release x.y.z`) that bumps `pubspec.yaml`, `.release-please-manifest.json` and prepends the new section to `CHANGELOG.md`.
2. Merging that PR creates the GitHub release and pushes the tag `vX.Y.Z`.
3. The tag push runs `.github/workflows/publish_to_pubdev.yml`, which publishes to pub.dev.

`release.yml` uses the `IMPAKTFULL_GITHUB_PAT` secret instead of `GITHUB_TOKEN`: a tag pushed with `GITHUB_TOKEN` does not trigger other workflows, and pub.dev only accepts publishes triggered by a tag push. The token needs Contents, Pull requests and Issues as "Read and write" on this repository.

To force a specific version (e.g. a pre-release), set `"release-as": "x.y.z"` in `release-please-config.json` and remove it again after that release is merged. `pubspec.yaml` must always hold a plain `x.y.z` version: release-please keeps anything after it as a build suffix (`1.0.0-dev.1` would become `1.0.0+-dev.1`).

### More than one changelog entry per pull request

A pull request that changes several things documents each of them in the changelog: put one Conventional Commit line per change in the **commit message body**, separated by blank lines. release-please turns every line into its own entry. The repository squash-merges with the commit messages as the body, so the lines must be in the branch's commits (check them in the squash dialog before merging).

```
feat: add a new command

fix: subprocesses inherit PATH on Linux CI

deprecate: OldName, use NewName
```

`deprecate:` lines are listed under **Deprecations** (configured in `changelog-sections` of `release-please-config.json`). They do not trigger a release on their own, so a pull request that deprecates something always also has a `feat:` title for the replacement.
