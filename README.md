# Offline PDF Tool

Offline-first Flutter app targeting Windows, macOS, iOS, and Android.

## V1 Features
- PDF merge, split, rotate, reorder/delete pages (engine-first implementation).
- HTML -> PDF.
- Markdown -> PDF.
- JSON -> PDF.
- Image <-> PDF.
- Lightweight single-task flow (one operation at a time).

## Setup
Use the team-standard setup in [DEV_SETUP.md](docs/DEV_SETUP.md).

## Current State
This repository contains a production-ready architecture scaffold and feature wiring.
Platform conversion backends are implemented as pluggable adapters in `lib/src/infrastructure`.

## Run
- `fvm flutter pub get`
- `fvm flutter run`

## Test
- `fvm flutter test`
