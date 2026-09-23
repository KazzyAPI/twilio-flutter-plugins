# Releases (Release Please)

This repo uses [Release Please](https://github.com/googleapis/release-please) to maintain per-package `CHANGELOG.md` files, bump `pubspec.yaml` versions, cut GitHub releases with tags, and (when configured) publish to [pub.dev](https://pub.dev).

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
6. If `PUB_DEV_TOKEN` is configured (see below), the same workflow publishes any package that was released on that push (**core first**, then conversations and video).

## pub.dev setup (one-time)

### 1. Create a publisher and claim package names

1. Sign in at [pub.dev](https://pub.dev) with the Google account that will own releases.
2. Create a **publisher** (org or individual) if you do not have one.
3. Ensure you are allowed to publish `twilio_flutter_core`, `twilio_flutter_conversations`, and `twilio_flutter_video` (first successful publish claims the name).

**Order matters:** publish **`twilio_flutter_core`** before the Flutter plugins. Plugin `pubspec.yaml` files depend on `twilio_flutter_core` on pub.dev; the publish job runs core first when multiple packages release on the same push.

### 2. Create a CI upload token

1. Open [pub.dev account → Tokens](https://pub.dev/account/tokens) (or run `dart pub token add https://pub.dev` locally and copy a dedicated CI token).
2. Create a token scoped for automated upload (follow pub.dev’s current guidance for long-lived CI tokens).
3. In GitHub: **Settings → Secrets and variables → Actions → New repository secret**
   - Name: **`PUB_DEV_TOKEN`**
   - Value: the pub.dev token

The publish job sets `PUB_TOKEN` from this secret (what `dart pub` / `flutter pub` expect in CI).

If `PUB_DEV_TOKEN` is missing, Release Please and GitHub releases still run; pub.dev publish is skipped.

### 3. Verify locally (optional)

From a package directory, with a token exported:

```bash
export PUB_TOKEN="…"
cd packages/twilio_flutter_core
dart pub publish --dry-run
```

For plugins:

```bash
cd packages/twilio_flutter_conversations
flutter pub publish --dry-run
```

## Monorepo dependencies vs pub.dev

Published `pubspec.yaml` files use **hosted** constraints (for example `twilio_flutter_core: ^0.0.1`). Local development uses **`pubspec_overrides.yaml`** (gitignored) to point at `../twilio_flutter_core`:

- Run `./scripts/bootstrap.sh` or `./scripts/link_pubspec_overrides.sh` after clone.
- CI runs `link_pubspec_overrides.sh` before `pub get`.

Templates: `packages/*/pubspec_overrides.yaml.example`.

When core has a breaking bump, update the minimum constraint in plugin `pubspec.yaml` in the same change set as the API that requires it.

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

Manual publish (emergency):

```bash
export PUB_TOKEN="…"
./scripts/publish_pub_dev_releases.sh
# with PUBLISH_TWILIO_FLUTTER_* env vars set to true for the packages you need
```
