# TodoList – iOS Test Task
SwiftUI · VIPER · Core Data · GCD · 92%+ tests

## What It Shows
Production‑style ToDo: list, create, edit (auto‑save on back), delete, toggle done, search, long‑press actions, share, pull‑to‑refresh (re‑imports), speech dictation for description, multiline titles.

## Stack & Structure
- Architecture: VIPER modules (`TodoList`, `TodoDetail`) + Clean layers (Domain / Infrastructure / Presentation)
- Persistence: Core Data (idempotent initial import) + offline fallback (`todos.json`)
- Network: fetch from https://dummyjson.com/todos on first launch or manual refresh
- Concurrency: background queues for all IO & mutations; main thread only for UI publish
- Design System: central Strings, Colors, Metrics, Spacing, Accessibility helpers
- Quality: SwiftLint, no magic literals, structured logging

## Tests
92%+ unit coverage (entities, use cases, repositories, presenters, formatting, network, speech). UI tests for main flows.

## Run
Open `TodoList.xcodeproj`, select `TodoList` scheme, Build & Run (Xcode 15+ compatible; built with Xcode 16).

## Key Files
- `AppAssembler.swift` – dependency wiring
- `Domain/UseCases.swift` – business actions
- `Infrastructure/CoreData/*` – persistence & mapping
- `Infrastructure/Network/NetworkClient.swift` – remote fetch
- `Presentation/TodoList` & `TodoDetail` – modules (Views + Presenter + Interactor)
- `Support/SpeechRecognizer.swift` – voice input

## Brief Assignment Match
CRUD, search, initial remote load, background threading, Core Data persistence, unit & UI tests, Xcode 15 compatibility, VIPER bonus.

Done.