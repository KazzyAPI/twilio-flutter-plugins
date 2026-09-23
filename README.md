# Twilio Flutter plugins

Flutter plugins that wrap Twilio’s **official** iOS and Android SDKs for real-time chat and video. You add one or both packages to your app, mint access tokens on your backend, and call typed Dart APIs instead of wiring native listeners yourself.

**Platforms:** iOS and Android only.

**Not included:** token minting, conversation/room administration, or API secrets in the app — those stay on your server.

---

## Packages

| Package | What it does |
| --- | --- |
| [`twilio_flutter_conversations`](packages/twilio_flutter_conversations) | Chat: connect with a JWT, sync conversations, send and receive messages (text and media), typing indicators, participant updates, token refresh events. |
| [`twilio_flutter_video`](packages/twilio_flutter_video) | Video rooms: connect with a JWT and room name, room/participant events, mute local audio/video. Rendering video on screen (platform views) is not in this release yet. |
| `twilio_flutter_core` | Shared error types and JSON helpers **inside this repo only** (`publish_to: none`). Not on pub.dev. |

Plugins are versioned with Release Please; consume them from **git** (see below) until pub.dev publishing supports bundled internal deps.

---

## Use in your app

Install, Android/iOS setup, backend tokens, and copy-paste examples:

**[Consumer guide → docs/CONSUMER_GUIDE.md](docs/CONSUMER_GUIDE.md)**

```yaml
dependencies:
  twilio_flutter_conversations:
    git:
      url: https://github.com/KazzyAPI/twilio-flutter-plugins.git
      path: packages/twilio_flutter_conversations
      ref: twilio_flutter_conversations-v0.0.1   # or a commit SHA on main
  # twilio_flutter_video: … same repo, path: packages/twilio_flutter_video
```

Git resolves `twilio_flutter_core` via the plugin’s `path:` dependency inside the cloned repo.

---

## Requirements

| | |
| --- | --- |
| Flutter | 3.47+ |
| Dart | 3.13+ |
| Android | min SDK 21 |
| iOS | 13.0+ |

Native Twilio SDK versions: [docs/COMPATIBILITY.md](docs/COMPATIBILITY.md).

---

## More documentation

| | |
| --- | --- |
| [API coverage](docs/API_COVERAGE.md) | What Twilio features are supported in Dart today |
| [Event catalog](docs/EVENT_CATALOG.md) | Conversations events |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Error codes and common failures |
| [Contributing](CONTRIBUTING.md) | Maintainers: Pigeon, tests, CI |
| [Releases](docs/RELEASES.md) | Release Please, changelogs, GitHub tags |

---

## License

[LICENSE](LICENSE)
