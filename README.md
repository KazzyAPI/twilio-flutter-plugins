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
| `twilio_flutter_core` | Shared error types and JSON helpers; pulled in by the plugins. You normally do not depend on it directly. |

Each package is published separately on pub.dev (this Git repo is not a single pub artifact).

---

## Use in your app

Install, Android/iOS setup, backend tokens, and copy-paste examples:

**[Consumer guide → docs/CONSUMER_GUIDE.md](docs/CONSUMER_GUIDE.md)**

```yaml
dependencies:
  twilio_flutter_conversations: ^0.1.0
  twilio_flutter_video: ^0.1.0   # optional
```

Use the versions on [pub.dev](https://pub.dev) when available.

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

---

## License

[LICENSE](LICENSE)
