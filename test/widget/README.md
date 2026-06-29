# Golden File Tests

This directory contains widget golden file tests for visual regression testing.

## Overview

Golden tests capture pixel-perfect snapshots of widgets and compare them against baseline images. They help catch unintended UI changes during development.

## Running Golden Tests

### Run all golden tests locally
```bash
flutter test --tags golden
```

### Update golden baselines after intentional UI changes
```bash
flutter test --tags golden --update-goldens
```

### Run only unit tests (excluding goldens)
```bash
flutter test --exclude-tags golden
```

## CI Pipeline

The CI pipeline separates golden tests from unit tests to ensure reproducible rendering:

1. **Unit Tests** - Run with `--exclude-tags golden` for fast feedback
2. **Golden Tests** - Run with `--tags golden` to verify UI against committed baselines

### Environment Requirements

Golden tests require a pinned, reproducible rendering environment:
- Exact Flutter version (3.44.2)
- Consistent platform (Ubuntu in CI)
- Same screen pixel density

### Updating Baselines in CI

To update golden baselines through CI:

1. Go to the Actions tab in GitHub
2. Select "Update Golden Baselines" workflow
3. Click "Run workflow"
4. The workflow will regenerate all golden files and commit them

## Best Practices

1. **Tag all golden tests** with `@Tags(['golden'])`
2. **Test both themes** (light and dark) when applicable
3. **Use consistent mock data** to ensure reproducible renders
4. **Review visual diffs** carefully before updating baselines
5. **Keep golden files small** by testing individual widgets rather than entire screens

## Troubleshooting

### Golden tests fail locally but pass in CI
Your local environment differs from CI. Either:
- Run tests in a Docker container matching CI environment
- Accept that local goldens may differ and rely on CI for verification

### Golden tests fail in CI after dependency updates
Flutter or dependency updates may change rendering. Update baselines:
- Use the "Update Golden Baselines" workflow
- Review the diff before merging

### Golden files missing
Run `flutter test --tags golden --update-goldens` to generate baseline files.
