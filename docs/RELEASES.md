# Releases (Release Please + pub.dev)

This repo ships through **pull requests to `main`**, then **Release Please release PRs**, then **GitHub tags** that trigger [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing) (OIDC — no long-lived upload token in GitHub).

References: [Publishing packages](https://dart.dev/tools/pub/publishing), [Automated publishing](https://dart.dev/tools/pub/automated-publishing).

## Packages

| Path | Pub package | Release Please tag |
| --- | --- | --- |
| `packages/twilio_flutter_core` | `twilio_flutter_core` | `twilio_flutter_core-v0.0.2` |
| `packages/twilio_flutter_conversations` | `twilio_flutter_conversations` | `twilio_flutter_conversations-v0.0.2` |
| `packages/twilio_flutter_video` | `twilio_flutter_video` | `twilio_flutter_video-v0.0.2` |

Configuration: [`release-please-config.json`](../release-please-config.json) and [`.release-please-manifest.json`](../.release-please-manifest.json).

## End-to-end flow (PRs → main → pub.dev)

```text
Feature/fix PR  ──merge──►  main
                              │
                              ▼
              Release Please opens/updates a Release PR (per package)
                              │
                              ▼
              Review changelog + version bump  ──merge Release PR──►  main
                              │
                              ▼
              Release Please creates GitHub Release + git tag on main
                              │
                              ▼
              Tag push runs publish-pub-dev.yml  ──OIDC──►  pub.dev
```

1. **Day-to-day work:** open a PR into `main` (required for production changes). Use [Conventional Commits](https://www.conventionalcommits.org/) on commits that touch `packages/<name>/`.
2. **After merges to `main`:** [Release Please](../.github/workflows/release-please.yml) opens or updates **Release PR(s)** (`separate-pull-requests: true`).
3. **Ship a version:** review and **merge the Release PR into `main`** (another PR — do not bump versions by hand on a direct push).
4. **GitHub release + tag:** Release Please creates the release and tag (for example `twilio_flutter_core-v0.0.2`).
5. **pub.dev:** [`.github/workflows/publish-pub-dev.yml`](../.github/workflows/publish-pub-dev.yml) runs on that tag push and publishes via the official `dart-lang/setup-dart` reusable workflow and OIDC.

pub.dev **rejects** publishes from Actions that were not triggered by a **tag push** — that is why publishing is separate from the Release Please job.

## pub.dev setup (one-time per package)

### 1. Verified publisher (recommended)

Follow [Create a verified publisher](https://dart.dev/tools/pub/publishing#create-a-verified-publisher) on pub.dev (domain verification via Search Console).

### 2. First version (manual)

Automated publishing only works for **existing** packages. Publish **once** by hand:

```bash
export PUB_TOKEN="…"   # from https://pub.dev/account/tokens
cd packages/twilio_flutter_core
dart pub publish --dry-run
dart pub publish
```

Repeat for each plugin after `twilio_flutter_core` is on pub.dev. New packages under a verified publisher may need a [documented workaround](https://dart.dev/tools/pub/publishing#publish-to-pubdev) (publish to a Google account first, then transfer to the publisher).

**Order:** `twilio_flutter_core` before conversations/video (hosted dependency).

### 3. Enable GitHub Actions publishing (per package)

For each package, open **Admin** → **Automated publishing** → **Enable publishing from GitHub Actions**:

| Package | Repository | Tag pattern on pub.dev |
| --- | --- | --- |
| `twilio_flutter_core` | `KazzyAPI/twilio-flutter-plugins` | `twilio_flutter_core-v{{version}}` |
| `twilio_flutter_conversations` | same | `twilio_flutter_conversations-v{{version}}` |
| `twilio_flutter_video` | same | `twilio_flutter_video-v{{version}}` |

Tag patterns must match Release Please (`include-component-in-tag` + `include-v-in-tag` in config) and the regexes in `publish-pub-dev.yml`.

Optional hardening on pub.dev / GitHub: require a [GitHub Actions environment](https://dart.dev/tools/pub/automated-publishing#hardening-security-with-github-deployment-environments) (for example `pub.dev`) and tag protection rules.

No `PUB_DEV_TOKEN` secret is required for CI when OIDC is configured.

### 4. Prepare packages (pub.dev requirements)

- `LICENSE`, `README.md`, `CHANGELOG.md` in each package directory
- Hosted dependencies only in published `pubspec.yaml` (no `path:` deps)
- Run `dart pub publish --dry-run` locally before the first automated tag

## Monorepo local development

Published `pubspec.yaml` files use hosted constraints (`twilio_flutter_core: ^0.0.1`). Local development uses gitignored **`pubspec_overrides.yaml`**:

- `./scripts/bootstrap.sh` or `./scripts/link_pubspec_overrides.sh`
- CI runs `link_pubspec_overrides.sh` before `pub get`

Templates: `packages/*/pubspec_overrides.yaml.example`.

## Commit messages (Release Please)

| Prefix | Version bump (0.x) |
| --- | --- |
| `fix:` | patch |
| `feat:` | minor |
| `feat!:` or `BREAKING CHANGE:` | minor until 1.0 |

Examples:

```text
feat(conversations): add getParticipants host API
fix(video): map disconnect errors to TwilioErrorCode
```

## Bootstrap / history

- Versions in [`.release-please-manifest.json`](../.release-please-manifest.json) must match each `pubspec.yaml`.
- One-time `"bootstrap-sha"` in `release-please-config.json` limits the first Release PR changelog window; remove after the first release PR merges.

## Emergency manual publish

Local upload still uses a pub.dev token:

```bash
export PUB_TOKEN="…"
cd packages/twilio_flutter_core && dart pub publish --dry-run && dart pub publish
```

Do not tag manually unless you intend to trigger automated publishing for that version.
