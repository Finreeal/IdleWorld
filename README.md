# Idle World

Idle World is an iPhone-first SwiftUI concept for turning time away from the phone into visible game progress on the Home Screen.

This repository currently contains:

- MVP product and technical documentation
- Swift source scaffolding for the main app and a WidgetKit extension
- A Ruby project generator script that can create an Xcode project once the `xcodeproj` gem is available

## MVP shape

- `IdleWorldApp`: SwiftUI iOS app with onboarding, a base dashboard, and a tiny upgrade shop
- `GameStore`: shared game state persisted via `UserDefaults` in an App Group
- `FocusSessionManager`: records background/foreground timestamps and converts offline time into resources
- `IdleWorldWidget`: medium widget that surfaces camp progress directly on the Home Screen

## Current constraints

Pure iOS apps cannot perfectly infer "the user is not touching the phone at all" in the background without platform limitations. The MVP in this repo uses app lifecycle timestamps as the first validation step:

- when the app goes to background, a focus timestamp is stored
- when it returns, elapsed time is converted into resources
- widget timelines are reloaded after state changes

That is enough to validate the core loop and widget reliability before moving to Live Activities, Screen Time APIs, or richer anti-scroll rules.

## Generate the Xcode project

1. Install the Ruby dependency:

```bash
gem install --user-install xcodeproj
```

2. Generate the project:

```bash
ruby scripts/generate_project.rb
```

For a project that can be installed on a real iPhone, it is better to generate it with your own signing values:

```bash
APPLE_TEAM_ID=YOURTEAMID \
IDLEWORLD_APP_BUNDLE_ID=com.yourname.idleworld \
IDLEWORLD_WIDGET_BUNDLE_ID=com.yourname.idleworld.widget \
IDLEWORLD_APP_GROUP=group.com.yourname.idleworld \
ruby scripts/generate_project.rb
```

3. Open `IdleWorld.xcodeproj` in Xcode and set up signing plus the shared App Group:

- `group.com.finreeal.idleworld`

## Running on a physical device

If Xcode only says the app built successfully but does not install it on your iPhone, check these in this order:

1. In `Signing & Capabilities`, set the same Apple Team for both `IdleWorld` and `IdleWorldWidgetExtension`.
2. Make sure both bundle identifiers are unique under your Apple account.
3. Make sure the app and widget both use the same App Group value.
4. If you regenerated the project, confirm the team did not get reset to empty.
5. Build and run the main `IdleWorld` app target, not the widget extension target.

This project uses:

- an app target
- a widget extension
- a Device Activity monitor extension scaffold
- App Group entitlements
- Health permission text
- Live Activities support

Because of that, simulator or no-sign builds can pass while real-device installation still fails until signing is fully configured.

## Screen Time / Family Controls checklist

The repository now contains a prepared Screen Time scaffold, but real testing on iPhone still requires Apple-side setup:

1. In Xcode, add the `Family Controls` capability to:
- `IdleWorld`
- `IdleWorldScreenTimeMonitorExtension`

2. Keep the same App Group on:
- `IdleWorld`
- `IdleWorldWidgetExtension`
- `IdleWorldScreenTimeMonitorExtension`

3. Use a unique bundle ID for the new monitor extension too, for example:
- `com.yourname.idleworld.monitor`

4. Apple requires approval for the Family Controls entitlement before full App Store or device behavior can be trusted.

5. Without that capability, the app still opens, but the `Screen Time experiment` section in Studio will only behave as a scaffold and authorization or monitoring can fail with system errors.

## Repository layout

- `Docs/IdleWorldMVP.md`
- `App/`
- `Shared/`
- `WidgetExtension/`
- `scripts/generate_project.rb`

## Looking for visual help

I am looking for help with the visual side and animations.

The current SwiftUI output from the generator still feels too flat. If you are comfortable with SwiftUI `Canvas`, `TimelineView`, particle effects, or integrating Lottie animations, your Pull Request is very welcome.
