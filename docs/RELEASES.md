# Releases (Release Please)

## Packages

| Path | Released? | Notes |
| --- | --- | --- |
| `packages/twilio_flutter_core` | **No** (`publish_to: none`) | Shared only inside this repo via `path:` |
| `packages/twilio_flutter_conversations` | Yes (Release Please + git tags) | Public plugin |
| `packages/twilio_flutter_video` | Yes (Release Please + git tags) | Public plugin |

Release Please config: [`release-please-config.json`](../release-please-config.json), [`.release-please-manifest.json`](../.release-please-manifest.json).

## Flow (PRs → main → tags)

1. Merge feature/fix **PRs into `main`** (conventional commits under `packages/twilio_flutter_conversations/` or `…/video/`).
2. Release Please opens/updates a **Release PR** per plugin.
3. Merge the Release PR → GitHub release + tag (`twilio_flutter_conversations-v0.0.2`, etc.).
4. App developers depend on that **git ref** (see [README](../README.md) and [CONSUMER_GUIDE.md](CONSUMER_GUIDE.md)).

## Why core is not published

`twilio_flutter_core` is an internal library. Plugins declare:

```yaml
twilio_flutter_core:
  path: ../twilio_flutter_core
```

That is correct for this monorepo. **pub.dev does not allow `path:` dependencies** in uploaded packages, so you cannot publish core separately *and* keep it “hidden” while also publishing plugins that depend on it via `path:` — unless you later add a **release-time vendoring** step or publish core too.

**Today:** ship plugins from **Git**; consumers clone the repo subtree and get core automatically.

## pub.dev (optional / later)

[Automated publishing](https://dart.dev/tools/pub/automated-publishing) for plugins is wired in [`.github/workflows/publish-pub-dev.yml`](../.github/workflows/publish-pub-dev.yml) but will **fail** while `pubspec.yaml` still uses `path: ../twilio_flutter_core`. Enable pub.dev Admin → GitHub Actions only after we solve bundling or change dependency strategy.

First manual upload (if you enable pub.dev later): `dart pub login`, then publish from `packages/twilio_flutter_conversations` — not from core.

## Commit messages

| Prefix | Bump (0.x) |
| --- | --- |
| `fix:` | patch |
| `feat:` | minor |

Changes under `packages/twilio_flutter_core/` do **not** trigger Release Please (core is not in the manifest).
