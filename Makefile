.PHONY: build test clean deploy-android deploy-ios build-ffi run lint format help

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \\033[36m%-20s\\033[0m %s\\n", $$1, $$2}'

build-ffi: ## Build Core Engine FFI libraries
	@echo "Building Core Engine FFI..."
	cd ../core-engine && cargo build --release
	@echo "FFI libraries built"

run: ## Run on connected device
	flutter run

test: ## Run all tests
	@echo "Running tests..."
	flutter test
	@echo "Tests complete"

test-unit: ## Run unit tests only
	flutter test test/unit/

test-widget: ## Run widget tests only
	flutter test test/widget/

test-integration: ## Run integration tests
	flutter test test/integration/

coverage: ## Generate coverage report
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "Report: coverage/html/index.html"

lint: ## Run static analysis
	flutter analyze
	@echo "Linting complete"

format: ## Format all Dart code
	dart format lib/ test/

build: ## Build release artifacts
	@echo "Building release..."
	flutter build apk --release
	flutter build ios --release
	@echo "Build complete"

deploy-android: ## Deploy to Play Store
	@echo "Deploying Android..."
	flutter build appbundle --release
	@echo "Upload to Play Store Console"

deploy-ios: ## Deploy to App Store
	@echo "Deploying iOS..."
	flutter build ios --release
	@echo "Upload to App Store Connect"

clean: ## Clean build artifacts
	flutter clean
	rm -rf build/ .dart_tool/
	@echo "Cleaned"

generate: ## Run code generation
	flutter pub run build_runner build --delete-conflicting-outputs
