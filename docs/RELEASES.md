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

### What pub.dev does *not* have

- **No “create package” screen.** A package is created the first time a version is **uploaded** successfully (`dart pub publish` or tag-triggered CI).
- **No required “tokens” web page** for our GitHub flow. Older docs linked `pub.dev/account/tokens`; that URL is often missing. Use **`dart pub login`** (browser) for a one-time manual upload, or **`dart pub token add https://pub.dev`** only if you need a CLI-stored token ([`dart pub token`](https://dart.dev/tools/pub/cmd/pub-token)).
- **Automated publishing (OIDC)** is configured **per package** under that package’s **Admin** tab — only **after** the package exists on pub.dev.

### 1. Sign in on pub.dev

Use the **Google account** that should own uploads (personal or org). Confirm you’re signed in (avatar menu on [pub.dev](https://pub.dev)). If menu items are missing, you’re usually logged out or on the wrong account.

### 2. Verified publisher (optional but recommended)

Avatar menu → **Create publisher** → verify a domain you control ([Search Console](https://search.google.com/search-console)).  
**Note:** You cannot publish a **brand-new** package *directly* onto a verified publisher in one step. Typical path: publish the first version with your **Google account**, then **Admin → Transfer to publisher** ([pub.dev docs](https://dart.dev/tools/pub/publishing#publish-to-pubdev)).

### 3. First version (manual, from this repo)

Automated tag publishing only works after the package **already exists** on pub.dev.

```bash
./scripts/link_pubspec_overrides.sh   # local dev only; not used for publish contents
dart pub login                        # opens browser; authorizes pub to upload
cd packages/twilio_flutter_core
dart pub publish --dry-run            # fix any errors first
dart pub publish                      # confirm when prompted — creates the package name
```

Repeat for each plugin **after** `twilio_flutter_core` is on pub.dev (`twilio_flutter_conversations`, then `twilio_flutter_video`). Use `flutter pub publish` in plugin dirs if you prefer; `dart pub publish` also works for Flutter packages when the Flutter SDK is on your `PATH`.

If `dart pub login` prints an error after “Successfully authorized”, credentials may still be saved ([known pub issue](https://github.com/dart-lang/pub/issues/3424)). Try `dart pub publish --dry-run` anyway, or `dart pub logout` and log in again with the correct Google account.

**Order:** `twilio_flutter_core` before conversations/video (hosted dependency in `pubspec.yaml`).

### 3. Enable GitHub Actions publishing (per package)

For each package, open **Admin** → **Automated publishing** → **Enable publishing from GitHub Actions**:

| Package | Repository | Tag pattern on pub.dev |
| --- | --- | --- |
| `twilio_flutter_core` | `KazzyAPI/twilio-flutter-plugins` | `twilio_flutter_core-v{{version}}` |
| `twilio_flutter_conversations` | same | `twilio_flutter_conversations-v{{version}}` |
| `twilio_flutter_video` | same | `twilio_flutter_video-v{{version}}` |

Tag patterns must match Release Please (`include-component-in-tag` + `include-v-in-tag` in config) and the regexes in `publish-pub-dev.yml`.

Optional hardening on pub.dev / GitHub: require a [GitHub Actions environment](https://dart.dev/tools/pub/automated-publishing#hardening-security-with-github-deployment-environments) (for example `pub.dev`) and tag protection rules.

No GitHub **secret token** is required for CI when OIDC is configured (do not rely on a pub.dev “tokens” page for Actions).

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

```bash
dart pub login   # if not already authorized
cd packages/twilio_flutter_core && dart pub publish --dry-run && dart pub publish
```

Do not push a Release Please tag manually unless you intend to trigger automated publishing for that version.

## Stuck?

| Symptom | What to do |
| --- | --- |
| No tokens page on pub.dev | Normal for many accounts. Use `dart pub login` or `dart pub token add https://pub.dev` ([docs](https://dart.dev/tools/pub/cmd/pub-token)). |
| Can’t “create” a package in the UI | Publish from the CLI; the name is taken from `pubspec.yaml` `name:`. |
| 403 / not an uploader | Wrong Google account — `dart pub logout`, login with the account that owns the package. |
| Publisher / transfer confusion | First publish as uploader → package **Admin** → transfer to publisher. |
| Still blocked | Email [support@pub.dev](mailto:support@pub.dev) with package name and Google account email. |
