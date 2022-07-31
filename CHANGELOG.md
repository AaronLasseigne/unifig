# [0.3.1][] (2022-07-31)

## Fixed

- Frozen strings returned from providers caused an error.

# [0.3.0][] (2022-07-31)

## Changed

- Renamed some errors so they all end in `Error`.

## Added

- Raise an error if a two or more variable names result in the same method name.
- Any `nil` values are now handled here so providers don't have to worry about it.
- Variable substituion
- `Unifig::Vars` will now contain information about the loaded variables.

# [0.2.0][] (2022-07-24)

## Changed

- An environment is no longer required.

# [0.1.0][] (2022-07-18)

Initial release.

[0.3.1]: https://github.com/AaronLasseigne/unifig/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/AaronLasseigne/unifig/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/AaronLasseigne/unifig/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/AaronLasseigne/unifig/compare/v0.0.0...v0.1.0
