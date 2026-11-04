# Changelog

All notable changes to Arabesque are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-11-05

### Added

- Arabesque, a macOS input method for typing French and German letters on a US QWERTY keyboard with short ⌥ (Option) key sequences.
- The core table: ä ö ü ß ç é on one key each, à â æ è ê î ô œ ù û on two keys, and the tréma letters ë ï ü ÿ.
- The postfix tréma. With ⌥ held, e, i, u or y followed by `;` gives ë, ï, ü or ÿ. The dead key, `;` before the letter, gives the same four letters.
- Rules R1 to R16 for everything the core table leaves open. They cover one accented letter per hold, the underlined letter that becomes final, symbols on digit and punctuation keys, Delete and Esc, shortcuts, interruptions such as a mouse click, and autorepeat.
- Capitals: hold Shift as you press the letter, or turn on Caps Lock. The Shift tap, a tap on Shift before or after the letter while ⌥ is held, works too. The capital of ß is ẞ.
- `scripts/install.sh` to install or update Arabesque for your user account, and `scripts/uninstall.sh` to remove it.
- Documentation. `docs/RULES.md` has every rule, the symbol table and examples. The README has a cheat sheet, install, update and uninstall steps, a privacy section and a FAQ.
- Issue forms for bug reports and language requests, and a CI workflow that runs the tests and builds the app on macOS 15 and macOS 26.

[1.0.0]: https://github.com/jinzhuoli0908/arabesque/releases/tag/v1.0.0
