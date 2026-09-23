# Releases (Release Please)

This repo uses [Release Please](https://github.com/googleapis/release-please) to maintain per-package `CHANGELOG.md` files, bump `pubspec.yaml` versions, and cut GitHub releases with tags.

## Packages

| Path | Pub package | Tag example |
| --- | --- | --- |
| `packages/twilio_flutter_core` | `twilio_flutter_core` | `twilio_flutter_core-v0.0.2` |
| `packages/twilio_flutter_conversations` | `twilio_flutter_conversations` | `twilio_flutter_conversations-v0.0.2` |
| `packages/twilio_flutter_video` | `twilio_flutter_video` | `twilio_flutter_video-v0.0.2` |

Configuration: [`release-please-config.json`](../release-please-config.json) and [`.release-please-manifest.json`](../.release-please-manifest.json).

## Day-to-day flow

1. Merge work to `main` using [Conventional Commits](https://www.conventionalcommits.org/) (see below).
2. The [Release Please workflow](../.github/workflows/release-please.yml) runs on each push to `main`.
3. When there are releasable changes for a package, Release Please opens (or updates) a **Release PR** for that package (`separate-pull-requests: true`).
4. Review the PR: generated changelog entries and version bump in `pubspec.yaml`.
5. **Merge the Release PR** → Release Please creates the GitHub release and tag; manifest versions update on `main`.

Release Please does **not** publish to pub.dev. After a GitHub release, publish manually (or add a separate workflow) from each package directory.

## Commit messages

Release Please parses conventional commits scoped to files under each package path:

| Prefix | Version bump (0.x) |
| --- | --- |
| `fix:` | patch |
| `feat:` | minor |
| `feat!:` or `BREAKING CHANGE:` | minor until 1.0 (`bump-minor-pre-major`) |

Examples:

```text
feat(conversations): add getParticipants host API
fix(video): map disconnect errors to TwilioErrorCode
fix!: drop legacy connect overload
```

Use scopes that match the package when helpful; commits that only touch `packages/twilio_flutter_conversations/` affect that package’s release PR.

## First-time / bootstrap notes

- **Current versions** live in `.release-please-manifest.json` and must match each package’s `pubspec.yaml` `version:` before the first automated release.
- If the first Release PR includes too much history, add a one-time `"bootstrap-sha"` (full commit SHA) at the top of `release-please-config.json` — see [Release Please manifest docs](https://github.com/googleapis/release-please/blob/main/docs/manifest-releaser.md#bootstrapping). Remove it after the first release PR merges.

## Manual run (optional)

Maintainers can run locally with the CLI (`npm i -g release-please`) against this repo; CI on `main` is the source of truth for opening Release PRs.
