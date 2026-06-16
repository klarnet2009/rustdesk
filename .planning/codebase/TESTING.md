# Testing Patterns

**Analysis Date:** 2026-06-16

## Test Frameworks

### Rust (Backend)
- **Runner:** Built-in cargo test runner.
- **Run Commands:**
  ```bash
  cargo test                          # Run all backend tests
  cargo test --package name           # Test specific crate
  cargo test --lib test_name          # Test specific unit test
  ```

### Flutter (Frontend)
- **Runner:** Flutter test SDK.
- **Run Commands:**
  ```bash
  flutter test                        # Run all UI tests
  flutter test test/cm_test.dart      # Run specific test file
  ```

## Test File Organization

- **Rust:**
  - Unit tests are collocated in the same source files at the bottom inside `mod tests` marked with `#[cfg(test)]`.
- **Flutter:**
  - Tests are placed under `flutter/test/` directory.
  - File naming: `*_test.dart` suffix (e.g. `cm_test.dart`, `input_modifier_utils_test.dart`).

## Mocking & Fakes

- **Rust:**
  - Hardware elements (like screen capture DXGI structures) and OS events are mocked using standard trait abstractions or conditional compilations.
  - File system operations are often stubbed using mock directories.
- **Flutter:**
  - Utilizes standard Dart mock tools or manual stubbing to bypass native OS FFI calls during widget tests.

## Verification & Manual Testing

Because remote desktop software has deep hardware dependencies (GPU capture, virtual drivers, keyboard hooks), the majority of testing is done **manually** by:
1. Compiling the project (`python build.py`).
2. Setting up a local rendezvous server (`hbbs`/`hbbr`).
3. Running local host and client instances to test keyboard shortcuts, screen recording latency, clipboard transfer, and file synchronization.
4. Testing mobile client apps against desktop hosts.

---
*Testing analysis: 2026-06-16*
