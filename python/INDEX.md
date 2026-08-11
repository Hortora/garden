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
