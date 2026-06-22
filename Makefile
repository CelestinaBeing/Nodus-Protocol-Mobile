.PHONY: build-apk build-bundle build-ios test clean codegen

clean:
	flutter clean

codegen:
	dart run build_runner build --delete-conflicting-outputs

test:
	flutter test --exclude-tags golden

build-apk:
	bash scripts/build.sh apk

build-bundle:
	bash scripts/build.sh bundle

build-ios:
	bash scripts/build.sh ios
