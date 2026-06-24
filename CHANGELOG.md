# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] — 2026-06-24

### Added
- Version bumping script (`scripts/bump_version.sh`) for automated version management
- Build number now properly tracked in `pubspec.yaml` (`version: X.Y.Z+BUILD`)

### Changed
- Updated version from `1.0.0+1` to `1.1.0+2` to establish version bumping convention

## [1.0.0] — 2026-01-01

### Added
- **Pool Overview** (`lib/screens/pool_overview_screen.dart`): list of active pools with
  XLM/USDC reserves, price, and fee percentage; pull-to-refresh via `RefreshIndicator`
- **Wallet Screen** (`lib/screens/wallet_screen.dart`): SEP-10 authentication via Stellar
  secret key (on-device signing); displays connected address and token balances
- **PoolCard widget** (`lib/widgets/pool_card.dart`): pool list item with pair label,
  fee badge, reserve stats, price, and LP supply
- **TokenInput widget** (`lib/widgets/token_input.dart`): numeric input with token chip,
  `numberWithOptions(decimal: true)` keyboard, `FilteringTextInputFormatter` for decimal-only input
- **WalletProvider** (`lib/providers/wallet_provider.dart`): SEP-10 connection state machine
  (disconnected → connecting → connected/error); `connect()` guards against re-entry
- **PoolProvider** (`lib/providers/pool_provider.dart`): loads pool stats from backend;
  exposes `getQuote()` for swap estimation
- **TransactionProvider** (`lib/providers/transaction_provider.dart`): in-memory
  transaction list with `add()`, `updateStatus()`, and `clear()` methods
- **Token model** (`lib/models/token.dart`): XLM and USDC enum with `symbol` and `name` accessors
- **CI** (`.github/workflows/ci.yml`): Flutter setup, `flutter analyze --fatal-infos`,
  `flutter test --coverage`, release APK build

### Dependencies (key)
- `stellar_flutter_sdk: ^1.8.1` — SEP-10 challenge/response authentication
- `provider: ^6.1.1` — state management
- `dio: ^5.4.0` — HTTP client
- `hive: ^2.2.3` — local persistence
- `local_auth: ^2.2.0` — biometric authentication for transaction signing
- `intl: ^0.19.0` — number and date formatting

