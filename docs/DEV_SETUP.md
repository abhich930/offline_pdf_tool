# Developer Setup

## Recommended (team standard): FVM

1. Install FVM:
   - `dart pub global activate fvm`
2. Ensure pub global binaries are in PATH:
   - macOS zsh: add `export PATH="$PATH:$HOME/.pub-cache/bin"` to `~/.zshrc`
3. From repo root:
   - `fvm install`
   - `fvm use`
   - `fvm flutter pub get`
   - `fvm flutter test`

VS Code will automatically use `.fvm/flutter_sdk` via workspace settings.

## Alternative: global Flutter SDK

If you prefer not to use FVM:
1. Install Flutter SDK outside this repo (for example `~/development/flutter`).
2. Add Flutter to PATH.
3. Run:
   - `flutter pub get`
   - `flutter test`

Do not place the Flutter SDK inside this app repository.
