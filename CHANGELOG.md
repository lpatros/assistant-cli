# Changelog

## [1.3.0](https://github.com/lpatros/assistant-cli/compare/v1.2.0...v1.3.0) (2026-08-08)


### Features

* **channel:** save channel preference on switch ([a043b34](https://github.com/lpatros/assistant-cli/commit/a043b34a3687dd78a1c98d719305d25600bee11c))
* **cli:** add changelog command ([7f0c744](https://github.com/lpatros/assistant-cli/commit/7f0c744a960e0ad7227ad61cbc319dcb907ba5a7))
* **custom:** add command to inspect custom components ([204eed1](https://github.com/lpatros/assistant-cli/commit/204eed19a8dbc4d5d638836cb25833f18c1590db))
* **engine:** update engine execution logic ([e4eb16f](https://github.com/lpatros/assistant-cli/commit/e4eb16f971f012576a1e481e7b1ac83fb1ab629f))
* **locales:** update i18n translation keys ([8f7ee0c](https://github.com/lpatros/assistant-cli/commit/8f7ee0c70dbd88d02c88f6ee93409fb9e4eae779))
* **persistence:** persist update channel in config ([42a0c94](https://github.com/lpatros/assistant-cli/commit/42a0c9433d00f57adb1835884e2b994aa24508a8))
* **update:** add update to a specific version ([bd5ba3c](https://github.com/lpatros/assistant-cli/commit/bd5ba3c2f08301c46418d1eaec5da2da007df5c9))
* **update:** detect up-to-date state and show version ([5872436](https://github.com/lpatros/assistant-cli/commit/58724369421924cf40706928a8a1c57b7cbefe03))
* **update:** return to configured branch and persist channel ([0de71ab](https://github.com/lpatros/assistant-cli/commit/0de71ab1a30eab12ba0b620343ca7098c4a63348))


### Bug Fixes

* **engines:** surface stderr and exit status on output-file errors ([bee4110](https://github.com/lpatros/assistant-cli/commit/bee411040fd011978af7417d751ddd7ef149461a))
* **install:** properly escape args in assistant wrapper for windows ([d2b5c64](https://github.com/lpatros/assistant-cli/commit/d2b5c646b120efe28d1e0417a10e63279d5bca44))

## [1.2.0](https://github.com/lpatros/assistant-cli/compare/v1.1.0...v1.2.0) (2026-08-06)


### Features

* **channel:** add release channel switch command ([99e1905](https://github.com/lpatros/assistant-cli/commit/99e1905da1c9ae43a1ce696c7b1827ba924b01d8))


### Bug Fixes

* **version:** parse prerelease suffixes in changelog version ([8a84750](https://github.com/lpatros/assistant-cli/commit/8a84750094dd60253477886f2137e6b0b9c3d3bd))

## [1.1.0](https://github.com/lpatros/assistant-cli/compare/v1.0.0...v1.1.0) (2026-07-29)


### Features

* **update:** improve update flow with progress bar, conflict handling, and changelog viewer ([3fdb3e1](https://github.com/lpatros/assistant-cli/commit/3fdb3e19804096b10f4f202d125b50d10c03748c))
* **version:** add --version command ([2a2dea3](https://github.com/lpatros/assistant-cli/commit/2a2dea393dc4fcd4fdd8b6a36c6c82f12c1c5fcf))

## 1.0.0 (2026-07-29)


### Features

* add commit assistant skill ([a5fc150](https://github.com/lpatros/assistant-cli/commit/a5fc15087ad4d5bc90458acb82dc5e8fe84d651f))
* add core library modules ([61fb3b6](https://github.com/lpatros/assistant-cli/commit/61fb3b6d363be73c68f76bbe064a6f630c3ba14b))
* add custom skills support ([dfcc5ca](https://github.com/lpatros/assistant-cli/commit/dfcc5ca29ff1a22cfc6eb77d49a7cd6d6af5781f))
* add git dependency check before update and commit ([8c81e9d](https://github.com/lpatros/assistant-cli/commit/8c81e9d4994977f7c4555583052a31bbc64fa826))
* add interactive installer ([9593c35](https://github.com/lpatros/assistant-cli/commit/9593c35d56f3e62edba00996a87c826670c6063a))
* add localization support (en, pt-br) ([e26fa37](https://github.com/lpatros/assistant-cli/commit/e26fa37565d6216f6dfa3b4b3d228db18162910b))
* add project resume generator skill ([e19d94e](https://github.com/lpatros/assistant-cli/commit/e19d94ed5ead01eed02e8f4e48ddc82f1d0ff20f))
* add update subcommand for assistant self-update ([35281cc](https://github.com/lpatros/assistant-cli/commit/35281cc48945e54f959460cfb680b1bc14166575))
* add utility modules (colors, args, helpers) ([a3f9db6](https://github.com/lpatros/assistant-cli/commit/a3f9db6aaa6b36595e41c247ced673a133e6f4b8))
* **engine:** add engine installation guard ([2cac552](https://github.com/lpatros/assistant-cli/commit/2cac552fcabd04a1694c310cddd622fa9fcc9604))
* **i18n:** add Spanish locale and language navigation ([70dd124](https://github.com/lpatros/assistant-cli/commit/70dd124c8c1621bd867bf631d4543a4e5794f06c))
* **install:** add dependency checks for ollama and opencode ([5063f50](https://github.com/lpatros/assistant-cli/commit/5063f5036e94636099f5e368b1b7861a3f381999))
* **install:** add OS-aware default install directory ([8350a1c](https://github.com/lpatros/assistant-cli/commit/8350a1c1e0f23247a78403e8ee7d772186e8e27c))
* **install:** add PowerShell installer for Windows ([c881365](https://github.com/lpatros/assistant-cli/commit/c881365ab03b466854f567f5f63583e338713acf))
* **locale:** add custom locale support with fallback and listing ([c3a6e9a](https://github.com/lpatros/assistant-cli/commit/c3a6e9adbf41091ae5ede08d8a0552108f1bda18))
* **locales:** add i18n strings for custom skills ([e0b1b21](https://github.com/lpatros/assistant-cli/commit/e0b1b21f7286c3dab9b9b294905dacbff39fd837))
* **locales:** add translation strings for engine and git checks ([989fef3](https://github.com/lpatros/assistant-cli/commit/989fef30d2402636fbb31d113f9bfc3a3bea4798))
* **skills:** add overwrite protection for default skills ([19685a8](https://github.com/lpatros/assistant-cli/commit/19685a8326a55392778015c64476163cc788b242))
* **skills:** add readme command to generate README files ([ae036dd](https://github.com/lpatros/assistant-cli/commit/ae036dd28bc063864a174885eb336b8d7e71b865))
* **utils:** add _is_installed() helper ([34e85da](https://github.com/lpatros/assistant-cli/commit/34e85da07de39c6e96055eda011287a4e7d10dae))
* validate unknown commands and require quotes for messages ([e4355c5](https://github.com/lpatros/assistant-cli/commit/e4355c504698509f20965e3253c05afd0bd2a1c7))


### Bug Fixes

* **init:** resolve root from script path ([d22b73b](https://github.com/lpatros/assistant-cli/commit/d22b73bf584f13a0d54dca87fe2c04303a16caca))
* **init:** resolve script directory for ZSH and POSIX shells ([0c9d185](https://github.com/lpatros/assistant-cli/commit/0c9d1854a24c2b419cf9a9dfb8adb70a4e179880))
* **install:** read prompts from /dev/tty for pipe compatibility ([cc55951](https://github.com/lpatros/assistant-cli/commit/cc5595112468a9d138333513c8691cee264ca881))
