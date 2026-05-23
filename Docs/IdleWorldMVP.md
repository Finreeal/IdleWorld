# Idle World MVP

## Product goal

Idle World reframes "time away from the phone" as visible progress in a tiny world that lives on the Home Screen.

The first release should answer one question clearly:

Can we make users care about leaving the phone alone because they want to see their camp grow?

## MVP promise

- One compact fantasy camp world
- One resource loop: `gold` and `wood`
- One visible dashboard inside the app
- One medium widget on the Home Screen
- One lightweight onboarding that gets users to the widget fast

## Technical scope

### Platform

- iOS 17+
- SwiftUI
- WidgetKit
- App Groups for shared app/widget state

### State model

`GameState`

- `gold`
- `wood`
- `campLevel`
- `equippedTool`
- `lastBackgroundDate`
- `totalFocusedSeconds`
- `hasCompletedOnboarding`
- `unlockedDecorations`

`SessionLog`

- `startDate`
- `endDate`
- `duration`
- `goldEarned`
- `woodEarned`

`Upgrade`

- `id`
- `name`
- `goldCost`
- `woodCost`
- `goldRateBonus`
- `woodRateBonus`

## MVP loop

1. User opens the app for the first time.
2. Onboarding sells the idea and seeds starter resources.
3. User backgrounds the app and locks the phone.
4. When the app returns to foreground, the elapsed time is translated into resources.
5. Widget refreshes and the camp looks a bit more alive.

## Important platform note

The exact concept "count time only while the whole phone is locked and not being mindlessly used" is not fully exposed as a simple public background signal for third-party apps.

For the MVP we intentionally validate a narrower loop:

- track timestamps on app background and foreground
- optionally treat it as a "focus run"
- show accumulated progress in the widget

If this resonates, later phases can combine:

- manual focus session start
- Live Activities
- notification nudges
- optional Screen Time / Device Activity exploration

## UX direction

### Onboarding

1. Hook
   - black background
   - lonely hero in a dim camp
   - message: your hero only thrives when you stop feeding the scroll
2. Value
   - bright widget preview
   - promise: progress lives on the Home Screen
3. Activation
   - single CTA that seeds the world and moves to the dashboard

### Dashboard

- hero card with camp level
- two resource cards
- "last focus session" summary
- small upgrade shop
- widget setup hints

### Widget

- medium widget only in MVP
- camp scene header
- current resources
- status label:
  - `Working` after a productive return
  - `Resting` while the app is active

## Release blockers to test

- elapsed time is calculated correctly after foreground return
- state persists across cold launches
- widget reads the same shared state as the app
- onboarding is shown only once
- upgrades alter resource rates

## Suggested next step after MVP

Add an explicit "Deep Focus" action that starts a Live Activity, because it gives more control than trying to infer every unlock/lock edge case globally.
