
@echo off
set "PATH=%PATH%;C:\flutter\bin"
flutter_rust_bridge_codegen --skip-deps-check --rust-input src/flutter_ffi.rs --dart-output flutter/lib/generated_bridge.dart --c-output flutter/windows/runner/bridge_generated.h --rust-output src/bridge_generated.rs
