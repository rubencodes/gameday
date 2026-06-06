# gameday — contributor & agent guide

A minimal MLB "is it a gameday?" app (iOS / macOS / visionOS) with a configurable
widget and a Siri intent. This file captures the **critical, non-obvious** conventions —
most were learned the hard way. Read it before making structural changes.

## Architecture

Three source roots. `Shared/` compiles into **both** targets; `gameday/` is app-only; `widget/` is widget-only.

```
Shared/            Models + networking, used by app and widget
  Models/          MLBTeam, MLBVenue, GamedayFilter(Kind); GameInfo, GamedayInfo, GameState,
                   UpcomingGame (one model per file); MLBScheduleResponse (Codable API DTO)
  Services/        MLBService — URLSession schedule fetch
  Extensions/      Date+Extensions — cached formatters / schedule keys

gameday/           The app
  gamedayApp.swift                         @main; wipe-on-failure ModelContainer
  Views/           ContentView, DatePickerSheet, screen components, PlatformAdaptations;
                   Onboarding/ (OnboardingView + one file per page/component)
  ViewModels/      GamedayViewModel (@MainActor @Observable), FavoritesStore, NotificationManager
  Models/          GamedayCache (SwiftData @Model)
  Intents/         App-only Siri intent: CheckGamedayIntent, GamedayShortcuts, VenueEntity

widget/            The widget extension
  widgetBundle.swift                       @main bundle
  GamedayEntry / GamedayProvider / GamedayWidget   timeline entry, provider, configuration
  Views/           one file per widget view (GamedayWidgetView, WidgetAnswerView, accessory views, …)
  Intents/         SelectFilterIntent (WidgetConfigurationIntent), AppIntentTypes
                   (widget-only AppEntity/AppEnum conformances — see rule below)
```

Data flow: `MLBService` → neutral `GamedayInfo`/`GameInfo` → presentation derived per `GamedayFilter`
(the same headline logic feeds both app and widget). The app reads/writes a per-(filter, date)
SwiftData cache; the widget fetches directly in its timeline.

## Project generation (XcodeGen)

- **`project.yml` is the source of truth.** The `.xcodeproj` is generated and **gitignored** — never hand-edit `project.pbxproj`.
- Regenerate after **adding/removing/renaming files** (sources are globbed at generation time):
  ```sh
  mint run xcodegen generate          # version pinned in Mintfile (mint bootstrap on a fresh machine)
  ```
  Editing the *contents* of an existing file needs **no** regeneration.
- Targets: `gameday` (app, sources: `gameday/` + `Shared/`) and `widgetExtension` (sources: `widget/` + `Shared/`). `Shared/` compiles into **both**.

## Build / verify

```sh
xcodebuild -project gameday.xcodeproj -scheme gameday \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build      # iOS
xcodebuild -project gameday.xcodeproj -scheme gameday -destination 'platform=macOS' build
```
Build for **iOS and macOS** after any cross-platform change. (SourceKit may show
phantom "cannot find type" errors for `Shared/` types across targets — trust the build, not the squiggles.)

## AppIntents: register each intent type from exactly ONE module

This is the single most important rule. An `AppEntity` / `AppEnum` / `EntityQuery` /
`AppIntent` registered from two targets with the **same identifier** silently breaks
configuration resolution (widget falls back to defaults; Siri loops).

- The plain models (`MLBTeam`, `MLBVenue`, `GamedayFilterKind`) live in `Shared/` as **ordinary types**.
- The widget's AppIntents **conformances** live only in `widget/AppIntentTypes.swift`.
- The app's Siri intent uses its **own, distinctly-named** entity (`VenueEntity`) — never reuse the widget's `MLBVenue` AppEntity in the app.
- A *static* shared library/package would re-trigger the bug (types copied into both binaries). If shared AppIntents are ever needed, use a **dynamic** framework.

Other AppIntents notes:
- A `Switch` `parameterSummary` must reference the switched parameter (e.g. `\.$filterKind`) in **each** case, or its picker won't render.
- For Siri over a large set (e.g. 30 venues), use a **`String` parameter resolved manually** (`MLBVenue.search`), not an `AppEntity` parameter — entity disambiguation falls back to a pick-list and ignores the spoken value.
- `AppShortcut` phrases **must** contain `\(.applicationName)`; add synonyms via `INAlternativeAppNames` in `gameday/Info.plist`.

## Cross-platform

- App + widget support iOS / macOS / visionOS. Gate iOS-only SwiftUI behind `#if os(iOS)` via the helpers in `gameday/Views/PlatformAdaptations.swift` (toolbar placements, inline nav title, `fullScreenCover`, `presentationDetents`, wheel picker).
- **Lock Screen accessory widgets are iOS-only** (`AccessoryWidgetBackground`, the accessory `WidgetFamily` cases) — keep them under `#if os(iOS)`.
- **macOS App Sandbox**: both the app and the widget need `com.apple.security.app-sandbox` + `com.apple.security.network.client` (the widget makes its own fetches; a Mac widget extension won't even register without the sandbox). Entitlements files are scoped via `CODE_SIGN_ENTITLEMENTS[sdk=macosx*]` so iOS is untouched.

## Conventions

- **One top-level type per file** — models, views, view models, styles, all of them (e.g. each onboarding page and each widget view is its own file). Nest a type only when it's meaningful solely in its parent's context (e.g. `MLBScheduleResponse`'s parsing types, `GamedayFilter.DeepLink`).
- **No abbreviated names** — `viewModel` not `vm`, `formatter` not `f`, `normalizedQuery` not `q`.
- **Typed over stringly-typed** — e.g. `GameState` enum, not `"Live"`/`"Final"` literals.
- **Cache `DateFormatter`s** as `static let`; never allocate per call.
- View states use a `ViewState` enum (`loading` / `loaded` / `unavailable` / `error`); view models are `@MainActor @Observable`.
- Full-width custom buttons use a `ButtonStyle` with `contentShape` so the whole control is tappable (not just the label).
- When a tap both dismisses UI **and** triggers a reload, defer the reload (`Task { @MainActor in … }`) so the dismissal isn't batched behind it.

## MLB stats API (statsapi.mlb.com)

- `/api/v1/schedule` filters server-side by `teamId=` **or** `venueIds=` (venue filtering works — no client-side filtering needed).
- Distinguish a **missing `dates` key** (→ `.unavailable`) from a **present-but-empty array** (→ normal "no game").
- Map **all** games for a date (doubleheaders), not just the first.
- "Next game" lookups use a **bounded look-ahead window** (≤14 days), never an open-ended query.
- Set a request **timeout** so widget timelines can't hang.

## Caching gotchas (operational)

Schema/intent changes can be masked by aggressive system caches — a plain reinstall is often **not** enough:
- AppIntents registry (`appintentsd`): **erase the simulator** / reboot device.
- Widget metadata (`chronod`): quit-reopen the app, or `killall chronod`.
- SwiftData: the `ModelContainer` wipes-and-recreates the (disposable) cache on open failure — so cache-model changes are safe.
