| GE-20260414-c12931 | YAML frontmatter regex silently skips files with CRLF line endings | gotcha | 12/15 |
| GE-20260414-2a1cd1 | Regex-validated date strings still crash date.fromisoformat() on invalid calendar values | gotcha | 11/15 |
| GE-20260520-aa4a99 | Simulate missing Python package in subprocess-based tests via fake module on PYTHONPATH | technique | 10/15 |
| GE-20260414-10b7c8 | validate_examples.py silently skips any JSON block matching {[^}]*} as a template — use array-format JSON to test WARNING path | undocumented | 9/15 |
| GE-20260414-22e35f | Python Path.cwd() returns git worktree root, not main repo — scripts that use it to discover files find nothing | gotcha | 12/15 |
| GE-20260414-4bd3cb | validate_links.py uses requests.get not requests.head — wrong mock target causes silently-passing tests | undocumented | 9/15 |
| GE-20260414-7fbf58 | Python enum identity comparison silently returns False when module loaded twice via dual sys.path.insert | gotcha | 13/15 |
| GE-20260703-e0af92 | torch.onnx.export renamed use_external_data_format to external_data in PyTorch 2.12 — silent TypeError, no deprecation warning | gotcha | 11/15 |
| GE-20260730-6ea2ad | torch.onnx.export() requires onnxscript — undeclared dependency in PyTorch 2.13+ | gotcha | 8/15 |
| GE-20260730-2b2a0a | Path.exists() returns False for broken symlinks — use is_symlink() first | gotcha | 12/15 |
| GE-20260812-797a16 | Textual App subclass _dispatch_action name collision causes TypeError at key-press time | gotcha | 10/15 |
| GE-20260812-18a18e | Textual key events go to focused widget first — RichLog consumes up/down before siblings | gotcha | 10/15 |
| GE-20260812-b14978 | Textual widget testability via _build_display() — unit tests without mounting | technique | 9/15 |
| GE-20260814-ec28c4 | Empty dict is falsy — `x = x or default` silently ignores intentional empty overrides | gotcha | 8/15 |
| GE-20260814-e95775 | Injectable dispatch table for testing state-machine effect protocols | technique | 8/15 |
| GE-20260814-b47ed9 | Python dual-import identity mismatch — same file via sys.path and package import creates separate class objects | gotcha | 10/15 |
| GE-20260814-d6aad1 | Path('') silently resolves to CWD — is_dir() returns True for empty strings | gotcha | 10/15 |
| GE-20260820-1721bc | MSC dataset sparse feature vector layout is undocumented — directory naming inverts player perspective | undocumented | 12/15 |
| GE-20260820-5bb979 | numpy NpzFile decompresses the full array on every dict-style access — causes 30x memory bloat in loops | gotcha | 11/15 |
| GE-20260820-f7e922 | PyTorch BatchNorm running statistics corrupted by zero-feature samples in multi-source training | gotcha | 10/15 |
| GE-20260820-c12f8a | ML pipeline label mismatch when consolidation remaps classes but training reads original config | gotcha | 11/15 |
| GE-20260820-9fe8c4 | Dual-encoder additive fusion creates scale mismatch between one-modality and two-modality samples | gotcha | 9/15 |
| GE-20260820-146b15 | Modality dropout rate must approximate actual missing-modality distribution, not a fixed low percentage | technique | 11/15 |
| GE-20260820-a35da3 | Per-source accuracy breakdown is the key diagnostic for multi-source classifiers — confusion matrix alone is insufficient | technique | 10/15 |
| GE-20260821-80522d | Source proportion imbalance in multi-source ML training silently collapses model | gotcha | 11/15 |
| GE-20260821-4b0952 | Confusion matrix identifies architecture vs data bottleneck before hyperparameter tuning | technique | 9/15 |
| GE-20260821-a4982a | All-zero feature block detection as pre-merge data quality audit for multi-source ML | technique | 9/15 |
| GE-20260824-46ff2c | Path.write_text() is read-modify-write not append-only — truncates file first, crash loses all prior state | gotcha | 10/15 |
