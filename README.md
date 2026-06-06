# gameday

A minimalist app that answers one question: **is today a gameday?**

Pick an MLB team or a ballpark and gameday tells you — at a glance — whether there's a
game, who's playing, and when first pitch is. It runs on iPhone, iPad, Mac, and Apple
Vision Pro, with Home Screen and Lock Screen widgets, a Siri shortcut, and pre-game reminders.

## Features

- ✅ A big **YES / NO** for any team or ballpark, on any date up to a year out
- 📅 Next-game lookup and doubleheader support
- 🧩 Home Screen + Lock Screen widgets (configurable per team/venue)
- 🗣️ Siri: "is there a game today in gameday?"
- 🔔 Optional reminders before first pitch
- ⭐ Favorites for quick switching

## Requirements

- **Xcode 26** or later
- **macOS** recent enough to run that Xcode
- **[Mint](https://github.com/yonaskolb/Mint)** — used to run the project generator at a pinned version

## Getting started

This project's Xcode project is **generated** from a spec, so there's a one-time
generate step before you can open it.

1. **Install Mint** (if you don't have it):
   ```sh
   brew install mint
   ```

2. **Clone and enter the repo:**
   ```sh
   git clone <repo-url>
   cd gameday
   ```

3. **Install the pinned tooling** (reads `Mintfile`):
   ```sh
   mint bootstrap
   ```

4. **Generate the Xcode project:**
   ```sh
   mint run xcodegen generate
   ```

5. **Open and run:**
   ```sh
   open gameday.xcodeproj
   ```
   In Xcode, pick the **gameday** scheme and a destination (an iOS Simulator or My Mac), then press **Run** (⌘R).

That's it — you're up and running.

## Good to know

- `gameday.xcodeproj` is **generated and not committed**. If you add, remove, or rename
  files, re-run `mint run xcodegen generate`. (Editing existing files needs nothing.)
- Project settings live in **`project.yml`**, not the Xcode project.
- Contributing? See **`CLAUDE.md`** for the project's coding conventions and a few important gotchas.
