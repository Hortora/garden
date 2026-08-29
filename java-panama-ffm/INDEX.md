# java-panama-ffm Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0038 | Panama FFM native write/read on PTY slave fds causes SIGTRAP JVM crash in the next test class (macOS AArch64) | gotcha | 13/15 |
| GE-0053 | Panama FFM `IOC_OUT` ioctl returns success but leaves buffer zeroed (macOS AArch64, JVM mode) | gotcha | 13/15 |
| GE-0060 | tput silently reports 0 when TERM env var is absent in PTY integration tests | gotcha | 10/15 |
| GE-0061 | Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests | technique | 12/15 |
| GE-20260826-51c700 | sherpa-onnx FFM struct layout requires exact match of ALL nested model sub-configs — 17 types, not 5 | gotcha | 12/15 |
| GE-20260826-3608ec | sherpa-onnx native lib JARs contain JNI libs, not C API libs — FFM needs the shared-lib tarball | gotcha | 9/15 |
| GE-20260826-190329 | Oversized zero-filled allocation for FFM config structs — version-resilient alternative to exact MemoryLayout | technique | 11/15 |
| GE-20260829-c497e0 | OnnxRuntime C API tensor handles leak despite Java FFM Arena.ofConfined() cleanup | gotcha | 10/15 |
