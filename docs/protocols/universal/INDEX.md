# Universal Protocols

Technology-agnostic conventions applicable to any modular platform.

| Protocol | Rule |
|----------|------|
| [module-tier-structure](module-tier-structure.md) | Three-tier rule: pure-Java SPI / core library (no JPA) / full extension |
| [rest-adapter-module](rest-adapter-module.md) | REST layer in a separate opt-in module — never in core library runtime |
