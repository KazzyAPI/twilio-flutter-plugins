# Releases (Release Please + pub.dev)

Three packages on pub.dev: **`twilio_flutter_core`**, **`twilio_flutter_conversations`**, **`twilio_flutter_video`**.

Monorepo dev uses **hosted** constraints in `pubspec.yaml` and **`pubspec_overrides.yaml`** (from `*.example`) for path resolution — run `./scripts/link_pubspec_overrides.sh` or `./scripts/bootstrap.sh`.

## Flow

1. PRs merge to `main` (conventional commits under `packages/<name>/`).
2. Release Please opens/updates a Release PR per package.
3. Merge Release PR → GitHub release + tag (`twilio_flutter_core-v0.0.2`, etc.).
4. Tag push runs [publish-pub-dev.yml](../.github/workflows/publish-pub-dev.yml) (OIDC → pub.dev).

## First-time pub.dev (manual, once per package)

**Order:** core → conversations → video.

```bash
dart pub login
```

Enable **Automated publishing from GitHub Actions** on each package **Admin** tab after the first upload:

| Package | Tag pattern on pub.dev |
| --- | --- |
| `twilio_flutter_core` | `twilio_flutter_core-v{{version}}` |
| `twilio_flutter_conversations` | `twilio_flutter_conversations-v{{version}}` |
| `twilio_flutter_video` | `twilio_flutter_video-v{{version}}` |

Repository: **`KazzyAPI/twilio-flutter-plugins`**.

See [Automated publishing](https://dart.dev/tools/pub/automated-publishing).

## Commit messages

| Prefix | Bump (0.x) |
| --- | --- |
| `fix:` | patch |
| `feat:` | minor |
