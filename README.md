# [Unifig][]

Unifig lets you load external variables from one or more providers (e.g. local file, `ENV`).

[![Version](https://img.shields.io/gem/v/unifig.svg?style=flat-square)](https://rubygems.org/gems/unifig)
[![Test](https://img.shields.io/github/workflow/status/AaronLasseigne/unifig/Test?label=Test&style=flat-square)](https://github.com/AaronLasseigne/unifig/actions?query=workflow%3ATest)

## Installation

Add it to your Gemfile:

``` rb
gem 'unifig', '~> 0.1.0'
```

Or install it manually:

``` sh
$ gem install unifig --version '~> 0.1.0'
```

This project uses [Semantic Versioning][].
Check out [GitHub releases][] for a detailed list of changes.

## Usage

### Loading

Unifig loads a [YAML configuration][] which it uses to create methods allowing access to the variable values for a given environment.
Loading is handled through the `Unifig::Init` class and methods are made available on the `Unifig` class.
From `Unifig::Init` you can load the YAML as a string with `.load` or a file with `.load_file`.

All variables are converted into two methods on the `Unifig` class.
A predicate method shows whether the variable was provided and a regular method provides access to the value.

All variables are assumed to be required (not `nil` or a blank string).
They can be made optional using the `:optional` setting.
If there is a required variable without a value, Unifig will throw an error when loading.

``` rb
Unifig::Init.load(<<~YAML, :production)
  config:
    envs:
      development:
        providers: local
      production:
        providers: local

  HOST:
    value: github.com
    envs:
      development:
        value: localhost
  PORT:
    optional: true
    envs:
      development:
        value: 8080
YAML

> Unifig.host?
# true
> Unifig.host
# => "localhost"
> Unifig.port?
# true
> Unifig.port
# => 8080
```

If we replaced `:development` with `:production` inside the `load` call we'd get:

``` rb
> Unifig.host?
# true
> Unifig.host
# => "github.com"
> Unifig.port?
# false
> Unifig.port
# => nil
```

[API Documentation][]

### YAML Configuration

The configuration YAML must contain a `config` key.
Inside that all environments to be used must be listed under the `envs` key using the environment name.
Each environment must list a provider or providers that are checked in order to find the value for each variable.
Variables are then listed by name.

The first level of settings apply to all environments.
These can be overridden by setting the `envs` key and a key with the name of then environment and then redefining any settings.

### Providers

| Provider | Gem      |
| -------- | -------- |
| Local    | Built-in |

## Contributing

If you want to contribute to Unifig, please read [our contribution guidelines][].
A [complete list of contributors][] is available on GitHub.

## License

Unifig is licensed under [the MIT License][].

[Unifig]: https://github.com/AaronLasseigne/unifig
[Semantic Versioning]: http://semver.org/spec/v2.0.0.html
[GitHub releases]: https://github.com/AaronLasseigne/unifig/releases
[YAML configuration]: #yaml-configuration
[API Documentation]: http://rubydoc.info/github/AaronLasseigne/unifig
[our contribution guidelines]: CONTRIBUTING.md
[complete list of contributors]: https://github.com/AaronLasseigne/unifig/graphs/contributors
[the MIT License]: LICENSE.txt
