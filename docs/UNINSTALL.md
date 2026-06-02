# Uninstall Guide

This guide explains how to remove this project from your machine, with optional cleanup of Flutter/FVM/CocoaPods tooling.

## Option A: Remove Only This Project (Recommended)

```bash
rm -rf /Users/abhishekchauhan/Desktop/offline_pdf_tool
```

This removes:
- App source code
- Tests, docs, and sample files
- Project-local generated artifacts

## Option B: Remove Project + Flutter Tooling

### 1. Remove the project

```bash
rm -rf /Users/abhishekchauhan/Desktop/offline_pdf_tool
```

### 2. Uninstall Flutter SDK (Homebrew cask)

```bash
brew uninstall --cask flutter
```

### 3. Remove FVM and its managed SDK cache

```bash
dart pub global deactivate fvm
rm -rf ~/.fvm
```

### 4. Remove global Dart pub cache (optional, broader cleanup)

```bash
rm -rf ~/.pub-cache
```

Note: This removes all globally activated Dart tools, not just `fvm`.

### 5. Remove CocoaPods (if installed for this project)

If installed via Homebrew:

```bash
brew uninstall cocoapods
```

If installed via RubyGems:

```bash
sudo gem uninstall cocoapods
```

Optional CocoaPods cache cleanup:

```bash
rm -rf ~/.cocoapods
rm -rf ~/Library/Caches/CocoaPods
```

### 6. Remove PATH entries from shell config (optional)

Edit `~/.zshrc` and remove lines that add:
- Flutter path (for example `/opt/homebrew/Caskroom/flutter/latest/flutter/bin`)
- Dart pub global binaries (`$HOME/.pub-cache/bin`)

Reload shell:

```bash
source ~/.zshrc
```

### 7. Remove VS Code extensions (optional)

Uninstall these extensions from VS Code if no longer needed:
- `dart-code.flutter`
- `dart-code.dart-code`

## Quick Full Reset (Project + Tooling, excluding Xcode)

```bash
rm -rf /Users/abhishekchauhan/Desktop/offline_pdf_tool ~/.fvm ~/.pub-cache
brew uninstall --cask flutter
brew uninstall cocoapods
```

Use this only if you are sure you want everything removed.
