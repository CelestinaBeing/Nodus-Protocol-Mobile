#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: bump_version.sh <semver> <build_number>}"
BUILD="${2:?Usage: bump_version.sh <semver> <build_number>}"

# Validate semver format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in semver format (e.g., 1.1.0)"
    exit 1
fi

# Validate build number is an integer
if ! [[ "$BUILD" =~ ^[0-9]+$ ]]; then
    echo "Error: Build number must be a positive integer"
    exit 1
fi

# Update pubspec.yaml
sed -i "s/^version: .*/version: ${VERSION}+${BUILD}/" pubspec.yaml

# Verify
echo "Updated pubspec.yaml to version ${VERSION}+${BUILD}"
grep "^version:" pubspec.yaml