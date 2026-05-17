
# Write the comprehensive mobile README
readme_content = """# AMM Mobile App (Flutter)

Cross-platform mobile application for interacting with the AMM Liquidity Pool smart contracts. Built with **Flutter/Dart** for iOS and Android.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Architecture](#architecture)
- [Screens](#screens)
- [State Management](#state-management)
- [Wallet Integration](#wallet-integration)
- [Core Engine SDK](#core-engine-sdk)
- [API & Caching](#api--caching)
- [Build & Deploy](#build--deploy)
- [Testing](#testing)
- [Design System](#design-system)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Overview

The AMM Mobile App provides a clean, intuitive interface for users to:

- Deposit tokens into liquidity pools
- Remove liquidity and claim earned fees
- View current pool shares and earned incentives
- Execute token swaps with real-time price impact
- Monitor transaction status (Pending → Success/Failed)

**Target Platforms:** iOS 14+, Android API 26+

---

## Features

### Liquidity Management
- Add/Remove Liquidity forms with real-time estimation
- LP token share display with percentage impact
- Wallet balance validation before submission
- Slippage tolerance selector (0.1% - 5%)

### Swap
- Token swap with price impact display
- Exact-input and exact-output modes
- Slippage protection
- Route preview

### Wallet Integration
- Polkadot.js / SubWallet connection
- Transaction signing with biometric auth
- Balance display across all tokens
- Transaction history

### Responsive Design
- Adaptive layouts for phones and tablets
- Dark/Light theme support
- Accessibility labels and screen reader support

---

## Repository Structure

```
amm-mobile-app/
├── lib/
│   ├── main.dart                         # App entry point
│   ├── screens/
│   │   ├── liquidity_screen.dart         # Add/Remove Liquidity UI
│   │   ├── swap_screen.dart              # Token swap interface
│   │   ├── pool_overview_screen.dart     # Pool list & analytics
│   │   └── wallet_screen.dart            # Wallet & transaction history
│   │
│   ├── components/
│   │   ├── liquidity/
│   │   │   ├── add_liquidity_form.dart   # Token input + estimation
│   │   │   ├── remove_liquidity_form.dart # LP token input + estimation
│   │   │   ├── pool_share_display.dart   # Current share visualization
│   │   │   └── estimated_lp_tokens.dart  # Real-time LP token preview
│   │   └── swap/
│   │       ├── swap_card.dart            # Main swap container
│   │       ├── price_impact_display.dart # Impact percentage + warning
│   │       └── slippage_selector.dart    # Tolerance dropdown
│   │
│   ├── widgets/
│   │   ├── token_input.dart              # Reusable token amount input
│   │   ├── pool_card.dart                # Pool list item widget
│   │   ├── transaction_button.dart       # Sign + submit CTA
│   │   ├── loading_overlay.dart          # Full-screen loading state
│   │   └── error_banner.dart             # Inline error display
│   │
│   ├── providers/
│   │   ├── wallet_provider.dart          # Wallet connection state
│   │   ├── pool_provider.dart            # Pool data & caching
│   │   └── transaction_provider.dart     # Transaction lifecycle
│   │
│   ├── services/
│   │   ├── core_engine_service.dart      # Rust SDK FFI bridge
│   │   ├── contract_service.dart         # ink! contract interaction
│   │   ├── graphql_client.dart           # Backend API client
│   │   └── cache_service.dart            # Local persistence
│   │
│   ├── models/
│   │   ├── token.dart                    # Token metadata model
│   │   ├── pool.dart                     # Pool data model
│   │   ├── transaction.dart              # Transaction model
│   │   └── wallet_state.dart             # Wallet connection model
│   │
│   ├── utils/
│   │   ├── validation.dart               # Input validation logic
│   │   ├── formatters.dart               # Number/date formatters
│   │   ├── constants.dart                # App constants
│   │   └── extensions.dart             # Dart extensions
│   │
│   └── theme/
│       ├── app_theme.dart                # Theme configuration
│       ├── colors.dart                   # Color palette
│       └── typography.dart               # Text styles
│
├── test/
│   ├── unit/
│   │   ├── validation_test.dart          # Input validation tests
│   │   ├── formatters_test.dart          # Formatter tests
│   │   └── math_test.dart                # Core engine math tests
│   ├── widget/
│   │   ├── token_input_test.dart         # Token input widget tests
│   │   ├── pool_card_test.dart           # Pool card widget tests
│   │   └── liquidity_form_test.dart      # Form interaction tests
│   └── integration/
│       ├── liquidity_flow_test.dart      # End-to-end liquidity flow
│       └── swap_flow_test.dart           # End-to-end swap flow
│
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── MainActivity.kt
│
├── ios/
│   └── Runner/
│       ├── AppDelegate.swift
│       └── Info.plist
│
├── scripts/
│   ├── build.sh                          # Build for release
│   ├── test.sh                           # Run all tests
│   └── deploy.sh                         # Deploy to stores
│
├── docs/
│   ├── ARCHITECTURE.md                   # Detailed architecture
│   └── WALLET_INTEGRATION.md             # Wallet setup guide
│
├── pubspec.yaml                          # Dependencies
├── analysis_options.yaml                 # Lint rules
├── Makefile                              # Common commands
├── README.md                             # This file
└── .gitignore
```

---

## Architecture

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  ┌─────────┐ ┌─────────┐ ┌───────────┐ │
│  │ Screens │ │ Widgets │ │ Components│ │
│  └────┬────┘ └────┬────┘ └─────┬─────┘ │
│       │           │            │         │
│  ┌────▼───────────▼────────────▼─────┐  │
│  │        State (Providers)          │  │
│  │  WalletProvider | PoolProvider     │  │
│  └────┬─────────────┬────────────────┘  │
│       │             │                   │
│  ┌────▼─────┐  ┌────▼─────┐            │
│  │ Services │  │ Services │            │
│  │ Contract │  │ GraphQL  │            │
│  │ Service  │  │ Client   │            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│  ┌────▼─────────────▼────┐             │
│  │   Core Engine SDK     │             │
│  │   (Rust FFI Bridge)   │             │
│  └────────────────────────┘             │
└─────────────────────────────────────────┘
```

---

## Screens

### Liquidity Screen

```dart
class LiquidityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liquidity')),
      body: TabBarView(
        children: [
          AddLiquidityForm(),    // Deposit tokens
          RemoveLiquidityForm(), // Withdraw tokens
        ],
      ),
    );
  }
}
```

**Features:**
- Token pair selector (Token A / Token B)
- Real-time LP token estimation via Core Engine SDK
- Pool share impact preview
- Wallet balance validation
- Slippage tolerance setting
- Transaction status tracking

### Swap Screen

```dart
class SwapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwapCard(
        onSwap: (input, output) => _executeSwap(input, output),
      ),
    );
  }
}
```

**Features:**
- Token direction flip
- Price impact warning (>1% yellow, >5% red)
- Minimum received display
- Route information

### Pool Overview Screen

- List of all active pools
- TVL, volume, APY display
- User's positions
- Search and filter

### Wallet Screen

- Account balance overview
- Connected wallet address
- Transaction history
- Disconnect/reconnect

---

## State Management

Uses **Provider** pattern for reactive state:

```dart
// Wallet connection state
class WalletProvider extends ChangeNotifier {
  WalletState _state = WalletState.disconnected;
  
  Future<void> connect() async {
    _state = WalletState.connecting;
    notifyListeners();
    
    try {
      await _walletService.connect();
      _state = WalletState.connected;
    } catch (e) {
      _state = WalletState.error;
      _error = e.toString();
    }
    notifyListeners();
  }
}

// Pool data with caching
class PoolProvider extends ChangeNotifier {
  List<Pool> _pools = [];
  
  Future<void> loadPools() async {
    _pools = await _cacheService.getPools() ?? 
             await _graphqlClient.fetchPools();
    notifyListeners();
  }
}
```

---

## Wallet Integration

### Supported Wallets

- **SubWallet** (Primary)
- **Polkadot.js** (Extension)
- **Talisman** (Future)

### Connection Flow

```dart
class WalletService {
  Future<void> connect() async {
    // 1. Check if SubWallet is installed
    final isInstalled = await _checkSubWallet();
    if (!isInstalled) throw WalletNotInstalledException();
    
    // 2. Request connection
    final accounts = await _subWallet.enable('AMM App');
    
    // 3. Select default account
    _selectedAccount = accounts.first;
    
    // 4. Subscribe to balance changes
    _subscribeToBalance();
  }
  
  Future<String> signTransaction(Uint8List extrinsic) async {
    return await _subWallet.signer.signPayload({
      'address': _selectedAccount.address,
      'data': extrinsic,
    });
  }
}
```

### Transaction Signing

```dart
class TransactionButton extends StatelessWidget {
  final VoidCallback onSubmit;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show biometric prompt
        final authenticated = await _authenticate();
        if (!authenticated) return;
        
        // Sign and submit
        onSubmit();
      },
      child: Text('Confirm Transaction'),
    );
  }
}
```

---

## Core Engine SDK

The mobile app consumes the **Rust Core Engine** via FFI (Foreign Function Interface) for deterministic AMM math.

```dart
class CoreEngineService {
  static final DynamicLibrary _lib = Platform.isAndroid
      ? DynamicLibrary.open('libcore_engine.so')
      : DynamicLibrary.process();
  
  // Calculate swap output
  static double calculateSwapOutput({
    required double amountIn,
    required double reserveIn,
    required double reserveOut,
    required double feeNumerator,
    required double feeDenominator,
  }) {
    final func = _lib.lookupFunction<
      SwapOutputNative,
      SwapOutputDart
    >('calculate_swap_output');
    
    return func(amountIn, reserveIn, reserveOut, feeNumerator, feeDenominator);
  }
  
  // Calculate price impact
  static double calculatePriceImpact({
    required double amountIn,
    required double reserveIn,
    required double reserveOut,
  }) {
    final func = _lib.lookupFunction<
      PriceImpactNative,
      PriceImpactDart
    >('calculate_price_impact');
    
    return func(amountIn, reserveIn, reserveOut);
  }
}
```

**Benefits:**
- Zero floating-point discrepancies between mobile and contract
- Same math as on-chain (pure Rust)
- Works offline for estimation

---

## API & Caching

### GraphQL Client

```dart
class GraphQLClient {
  final HttpLink _httpLink = HttpLink('https://api.amm.app/graphql');
  
  Future<List<Pool>> fetchPools() async {
    final result = await _client.query(QueryOptions(
      document: gql(r'''
        query GetPools {
          pools {
            id
            token0 { symbol decimals }
            token1 { symbol decimals }
            reserve0
            reserve1
            totalSupply
            volume24h
            tvl
          }
        }
      '''),
    ));
    
    return (result.data!['pools'] as List)
      .map((json) => Pool.fromJson(json))
      .toList();
  }
  
  Future<PoolVolume> fetchPoolVolume(String poolId, int days) async {
    // Cached via Hive
    final cached = await _cacheService.getVolume(poolId, days);
    if (cached != null && cached.isFresh) return cached;
    
    final fresh = await _fetchFromApi(poolId, days);
    await _cacheService.setVolume(poolId, days, fresh);
    return fresh;
  }
}
```

### Cache Strategy

| Data Type | Cache Duration | Source |
|-----------|---------------|--------|
| Pool List | 5 minutes | GraphQL |
| User Balances | 30 seconds | On-chain |
| Transaction History | 1 minute | GraphQL |
| Price/Impact | Real-time | Core Engine SDK |
| Token Metadata | 1 hour | Static config |

---

## Build & Deploy

### Prerequisites

- Flutter 3.16+
- Dart 3.2+
- Android Studio / Xcode
- Rust toolchain (for Core Engine FFI)

### Setup

```bash
# Clone repo
git clone <repo-url>
cd amm-mobile-app

# Install dependencies
flutter pub get

# Build Core Engine FFI
make build-ffi

# Run code generation
flutter pub run build_runner build
```

### Development

```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (press 'r' in terminal)
```

### Build Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Deploy

```bash
# Deploy to Play Store
make deploy-android

# Deploy to App Store
make deploy-ios
```

---

## Testing

### Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Specific test
flutter test test/unit/validation_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Widget Tests

```bash
# Run widget tests
flutter test test/widget/

# Golden file tests
flutter test --update-goldens
```

### Integration Tests

```bash
# Requires running emulator/simulator
flutter test test/integration/

# Or use integration_test package
flutter drive --driver=test_driver/integration_test.dart --target=test/integration/liquidity_flow_test.dart
```

### Test Structure

```dart
// unit/validation_test.dart
group('Validation', () {
  test('rejects empty amount', () {
    expect(Validation.isValidAmount(''), isFalse);
  });
  
  test('rejects amount exceeding balance', () {
    expect(
      Validation.isWithinBalance(amount: 100.0, balance: 50.0),
      isFalse,
    );
  });
  
  test('accepts valid amount', () {
    expect(
      Validation.isValidAmount('10.5', decimals: 18),
      isTrue,
    );
  });
});

// widget/token_input_test.dart
testWidgets('TokenInput displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: TokenInput(token: Token.azero)),
  );
  
  expect(find.text('AZERO'), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget);
});
```

---

## Design System

### Colors

```dart
class AppColors {
  static const primary = Color(0xFF6C5DD3);
  static const secondary = Color(0xFF00B8D9);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
}
```

### Typography

```dart
class AppTypography {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white70,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white38,
  );
}
```

### Responsive Breakpoints

| Breakpoint | Width | Layout |
|-----------|-------|--------|
| Mobile | < 600px | Single column |
| Tablet | 600-900px | Two column |
| Desktop | > 900px | Three column |

---

## Troubleshooting

### Common Issues

**Build fails with FFI errors:**
```bash
# Rebuild Core Engine
make build-ffi

# Clean and rebuild
flutter clean
flutter pub get
```

**Wallet connection fails:**
- Ensure SubWallet/Polkadot.js is installed
- Check network matches (testnet vs mainnet)
- Verify app has internet permission

**RPC connection drops:**
- App shows offline banner
- Cached data displayed with stale indicator
- Auto-retry with exponential backoff

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

**Requirements:**
- All tests must pass (`flutter test`)
- Widget tests for new UI components
- Golden file updates if UI changes
- Dart format compliance (`dart format`)

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)
- [Polkadot{.js} Extension](https://polkadot.js.org/extension/)
- [SubWallet](https://subwallet.app/)
- [ink! Documentation](https://use.ink/)
"""

with open(f"{base}/README.md", "w") as f:
    f.write(readme_content)

# Write pubspec.yaml
pubspec = """name: amm_mobile_app
description: AMM Liquidity Pool Mobile Application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Network
  graphql_flutter: ^5.1.2
  dio: ^5.4.0
  
  # Wallet
  polkawallet_sdk: ^0.5.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # UI
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  flutter_slidable: ^3.0.1
  
  # Utils
  intl: ^0.19.0
  decimal: ^2.3.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # FFI (Core Engine)
  ffi: ^2.1.0
  
  # Security
  local_auth: ^2.2.0
  biometric_storage: ^5.0.1
  
  # Analytics
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/tokens/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
"""

with open(f"{base}/pubspec.yaml", "w") as f:
    f.write(pubspec)

# Write analysis_options.yaml
analysis = """include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_final_fields: true
    prefer_single_quotes: true
    always_specify_types: false
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true
    use_key_in_widget_constructors: true
    avoid_redundant_argument_values: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    prefer_relative_imports: true
    directives_ordering: true
    lines_longer_than_80_chars: false

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
"""

with open(f"{base}/analysis_options.yaml", "w") as f:
    f.write(analysis)

# Write Makefile
makefile = """.PHONY: build test clean deploy-android deploy-ios build-ffi run lint format help

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \\033[36m%-20s\\033[0m %s\\n", $$1, $$2}'

build-ffi: ## Build Core Engine FFI libraries
	@echo "🔨 Building Core Engine FFI..."
	cd ../core-engine && cargo build --release
	@echo " FFI libraries built"

run: ## Run on connected device
	flutter run

test: ## Run all tests
	@echo " Running tests..."
	flutter test
	@echo " Tests complete"

test-unit: ## Run unit tests only
	flutter test test/unit/

test-widget: ## Run widget tests only
	flutter test test/widget/

test-integration: ## Run integration tests
	flutter test test/integration/

coverage: ## Generate coverage report
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo " Report: coverage/html/index.html"

lint: ## Run static analysis
	flutter analyze
	@echo " Linting complete"

format: ## Format all Dart code
	dart format lib/ test/

build: ## Build release artifacts
	@echo "🔨 Building release..."
	flutter build apk --release
	flutter build ios --release
	@echo " Build complete"

deploy-android: ## Deploy to Play Store
	@echo " Deploying Android..."
	flutter build appbundle --release
	@echo "Upload to Play Store Console"

deploy-ios: ## Deploy to App Store
	@echo " Deploying iOS..."
	flutter build ios --release
	@echo " Upload to App Store Connect"

clean: ## Clean build artifacts
	flutter clean
	rm -rf build/ .dart_tool/
	@echo "🧹 Cleaned"

generate: ## Run code generation
	flutter pub run build_runner build --delete-conflicting-outputs
"""

with open(f"{base}/Makefile", "w") as f:
    f.write(makefile)

# Write .gitignore
gitignore = """# Flutter/Dart
.dart_tool/
.packages
build/
pubspec.lock
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ
*.iml
*.ipr
*.iws
.idea/

# VSCode
.vscode/

# Flutter/Dart/Pub
**/doc/api/
**/ios/Flutter/.last_build_id

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks

# iOS
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# macOS
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/macos/Flutter/ephemeral

# Coverage
coverage/
*.info

# Symbols
app.*.symbols

# Exceptions
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3
!**/ios/**/*/.symlinks/
"""

with open(f"{base}/.gitignore", "w") as f:
    f.write(gitignore)

# Write LICENSE
license_text = """MIT License

Copyright (c) 2026 AMM Platform Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

with open(f"{base}/LICENSE", "w") as f:
    f.write(license_text)

# Write scripts
build_sh = """#!/bin/bash
set -e

echo "🔨 Building AMM Mobile App..."

# Check prerequisites
if ! command -v flutter &> /dev/null; then
    echo " Flutter not found. Please install Flutter."
    exit 1
fi

# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Build Core Engine FFI
echo "Building Core Engine FFI..."
cd ../core-engine && cargo build --release

# Build Android
echo "Building Android..."
flutter build apk --release

# Build iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS..."
    flutter build ios --release
fi

echo " Build complete!"
echo "📱 Android: build/app/outputs/flutter-apk/app-release.apk"
echo "📱 iOS: build/ios/iphoneos/Runner.app"
"""

test_sh = """#!/bin/bash
set -e

echo "🧪 Running AMM Mobile App Test Suite..."

# Unit tests
echo "Running unit tests..."
flutter test test/unit/

# Widget tests
echo "Running widget tests..."
flutter test test/widget/

# Integration tests (if emulator available)
if flutter devices | grep -q "emulator\|simulator"; then
    echo "Running integration tests..."
    flutter test test/integration/
else
    echo "  No emulator/simulator found. Skipping integration tests."
fi

echo " All tests complete!"
"""

deploy_sh = """#!/bin/bash
set -e

PLATFORM=${1:-"android"}

echo "Deploying AMM Mobile App ($PLATFORM)..."

if [ "$PLATFORM" == "android" ]; then
    echo "Building Android App Bundle..."
    flutter build appbundle --release
    echo "Upload build/app/outputs/bundle/release/app-release.aab to Play Store"
    
elif [ "$PLATFORM" == "ios" ]; then
    echo "Building iOS archive..."
    flutter build ipa --release
    echo " Upload build/ios/ipa/*.ipa to App Store Connect"
    
else
    echo "Usage: ./deploy.sh [android|ios]"
    exit 1
