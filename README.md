# [Unifig][]

Unifig is a pluggable system for loading external variables from one or more providers (e.g. `ENV`).

[![Version](https://img.shields.io/gem/v/unifig.svg?style=flat-square)](https://rubygems.org/gems/unifig)
[![Test](https://img.shields.io/github/workflow/status/AaronLasseigne/unifig/Test?label=Test&style=flat-square)](https://github.com/AaronLasseigne/unifig/actions?query=workflow%3ATest)

## Installation

If you are using a framework you should install the associated gem:

| Framework | Gem              |
| --------- | ---------------- |
| Rails     | [unifig-rails][] |

If you want to use Unifig outside of a framework listed above you can manually add it to your project.

Add it to your Gemfile:

``` rb
gem 'unifig', '~> 0.3.1'
```

Or install it manually:

``` sh
$ gem install unifig --version '~> 0.3.1'
```

This project uses [Semantic Versioning][].
Check out [GitHub releases][] for a detailed list of changes.

## Usage

### Basics

Unifig loads a [YAML configuration][] that instructs it on how to retrieve various external variables.
These variable values come from providers.
Unifig comes with a `local` provider which reads values straight from the configuration file.
Additional providers may be installed.

The most minimal configuration would be:

```yml
config:
  providers: local

HELLO:
  value: "world"
```

Given that configuration, Unifig will attach two new methods to the `Unifig` class.
From in your code you can call `Unifig.hello` to get the value of the variable and `Unifig.hello?` to see if the value was retrieved (for optional values).

Unifig also allows you to override the overall configuration or the individual configuration by using environments.
Here is an example where the `production` environment only pull from the `env` provider and in the `test` environment `Unifig.hello` will return `dlrow`:

```yml
config:
  providers: [local, env]
    envs:
      production:
        providers: env

HELLO:
  value: "world"
  envs:
    test:
      value: "dlrow"
```

### Variable Substitutions

Variables can be used in other variables with `${VAR}`.

```rb
USER:
SERVICE_USERNAME: "${USER}_at_service"
```

Order of the variables does not matter but cyclical dependencies will throw an error.

### Loading

Loading a configuration is handled through the `Unifig::Init` class.
From `Unifig::Init` you can load the YAML as a string with `.load` or a file with `.load_file`.

All variables are assumed to be required (not `nil` or a blank string).
Variables can be made optional by using the `:optional` setting.
If there is a required variable without a value, Unifig will throw an error when loading.

```rb
Unifig::Init.load(<<~YAML, env: :production)
  config:
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

```rb
> Unifig.host?
# true
> Unifig.host
# => "github.com"
> Unifig.port?
# false
> Unifig.port
# => nil
```

You can load from a configuration file by using `load_file`.

```rb
Unifig::Init.load_file('unifig.yml', env: :production)
```

[API Documentation][]

### YAML Configuration

The configuration YAML must contain a `config` key.
A list of one or more providers must be given.
They are are checked in order to find the value for each variable.
Variables are then listed by name.

The first level of configurations apply to all environments.
These can be overridden by setting the `envs` key and a key with the name of then environment and then redefining any settings.
This is the case for the overall configuration as well as any variable configurations.

### Providers

| Provider | Gem            |
| -------- | -------------- |
| Local    | Built-in       |
| ENV      | [unifig-env][] |

### Unifig::Vars

After loading the configuration you can use `Unifig::Vars` to check on what happened.
It will return a list of `Unifig::Var`s with information such as which provider supplied the value.

## Contributing

If you want to contribute to Unifig, please read [our contribution guidelines][].
A [complete list of contributors][] is available on GitHub.

## License

Unifig is licensed under [the MIT License][].

[Unifig]: https://github.com/AaronLasseigne/unifig
[unifig-rails]: https://github.com/AaronLasseigne/unifig-rails
[Semantic Versioning]: http://semver.org/spec/v2.0.0.html
[GitHub releases]: https://github.com/AaronLasseigne/unifig/releases
[YAML configuration]: #yaml-configuration
[API Documentation]: http://rubydoc.info/github/AaronLasseigne/unifig
[our contribution guidelines]: CONTRIBUTING.md
[unifig-env]: https://github.com/AaronLasseigne/unifig-env
[complete list of contributors]: https://github.com/AaronLasseigne/unifig/graphs/contributors
[the MIT License]: LICENSE.txt
