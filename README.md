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
gem 'unifig', '~> 0.3.2'
```

Or install it manually:

``` sh
$ gem install unifig --version '~> 0.3.2'
```

This project uses [Semantic Versioning][].
Check out [GitHub releases][] for a detailed list of changes.

## Usage

### Basic

Unifig works by loading a YAML configuration that instructs it on how to retrieve and treat external variables.
Variable values are retrieved from an ordered list of providers.

A provider is any source where you would retrieve variable values.
Unifig comes with a `local` provider which reads values straight from the configuration file.
Additional providers may be installed:

| Provider | Gem            |
| -------- | -------------- |
| local    | Built-in       |
| env      | [unifig-env][] |

Providers are checked in order to find the variable values.
If a variable is not found in the first provider, it will be requested from the second provider and so on until it is found.

The YAML configuration should begin with a `config` key which lists the providers in the order you would like them checked:

```yml
config:
  providers: [local, env]
```

You can list a single provider or an ordered array to check.

Variables should be listed after the `config` key as their own keys.
Here's a mininal example YAML:

```yml
config:
  providers: local

HELLO: "world"
```

When this YAML is loaded, Unifig will add two methods to it's core `Unifig` class.
The first, `Unifig.hello` will return `"hello"` as the value it found from the `local` provider.
The second method, `Unifig.hello?` allow you to check to see if the value was able to be retrived at all.

```yml
> Unifig.hello?
# true
> Unifig.hello
# => "world"
```

Each variable listed in the YAML configuration will receive its own pair of methods on `Unifig`.

Variables can be listed with the `local` value immediately following as seen above.
They can also be defined with no `local` value:

```yml
HELLO:
```

Or they can be declared with the verbose syntax:

```yaml
HELLO:
  value: "world"
```

The verbose syntax is useful when additional configration is need as seen in the [Advanced](#advanced) section.

Loading a YAML configuration can be accomplished using the `Unifig::Init` class.
From `Unifig::Init` you can load the YAML as a string with `.load` or as a file with `.load_file`.

*NOTE: If you're using one of the framework gems, loading may be handled for you.*

Loading from a string:

```rb
Unifig::Init.load(<<~YML)
  config:
    providers: local

  HELLO: "world"
YML
```

Loading from a file:

```rb
Unifig::Init.load_file('unifig.yml')
```

### Advanced

#### Environments

Different working environments may require different setups.
This can be accomplished in the `config` key or within variable keys with the `envs` key.

Assuming two environments, `developement` and `production`, let's say we want to use different providers for each.
Whatever we set at the top level will operate as the default.
From there we can use the `envs` key to override that behavior:

```yml
config:
  providers: local
  envs:
    production:
      providers: env

HELLO: "world"
```

In the `development` environment we'll check the `local` provider but in `production` we'll use `env`.
This will result with `Unifig.hello` returning `"world"` in `development` and whatever the value of the `HELLO` environment variable is in `production`.
To select an environment, add it to `Unifig::Init.load` or `Unifig::Init.load_file`:

```rb
Unifig::Init.load(<<~YML, env: :development)
  config:
    providers: local
    envs:
      production:
        providers: env

  HELLO: "world"
YML
```

*NOTE: If you're using one of the framework gems, environments may be loaded automatically depending on the framework.*

In addition to changing `config`, `envs` may be used inside variables.
Any variable configuration may be overridden using `envs`:

```yml
HELLO:
  value: "world"
  envs:
    production:
      value: "universe"
```

Here we've set the `local` provider value to `"world"` for all environments with an override setting it to `"universe"` in the `production` environment.

#### Variable Substitutions

Variables can be used in other variables with `${VAR}`.

```rb
USER:
SERVICE_USERNAME: "${USER}_at_service"
```

Order of the variables does not matter but cyclical dependencies will throw an error.

#### Type Conversion

By default, all values are converted to strings.
If you want the value to be something other than a string you can assign a specific conversion.
Unifig comes with some basic built-in conversions or you can convert to any class available.

In order to convert a value you can provide a type to `convert`:

```yml
THREADS:
  value: 5
  convert: integer
```

Conversion works regardless of the provider of the value.

##### Built-in

There are a number of built-in types available.
Basic types that have no additional options include `string` (the default), `symbol`, `float`, and `decimal` (i.e. `BigDecimal`).

The `integer` type assumes base 10.
This can be overridden by providing a `base` option:

```yml
BINARY_INPUT:
  convert:
    type: integer
    base: 2
```

Unifig also provides `date`, `date_time`, and `time` all of which use `parse` by default.
Any of them can be provided with a `format` option if you want to specify the format of the input.
The `format` option uses `strptime` for the conversion.
You can find all valid formats by looking at the standard Ruby documentation.

```yml
STARTS_ON:
  convert:
    type: date
    format: %Y-%m-%d
```

##### Custom

Any available class can be used as a converter by providing the class name as the `converter`.
By default, `new` will be called on the class with the value passed in.
To use a different method provide it via the `method` option.

```yml
IP_ADDRESS:
  convert: IPAddr
ENCODING:
  convert:
    type: Encoding
    method: find
```

#### Unifig::Vars

After loading the configuration you can use `Unifig::Vars` to check on what happened.
It will return a list of `Unifig::Var`s with information such as which provider supplied the value.

[API Documentation][]

## Contributing

If you want to contribute to Unifig, please read [our contribution guidelines][].
A [complete list of contributors][] is available on GitHub.

## License

Unifig is licensed under [the MIT License][].

[Unifig]: https://github.com/AaronLasseigne/unifig
[unifig-rails]: https://github.com/AaronLasseigne/unifig-rails
[Semantic Versioning]: http://semver.org/spec/v2.0.0.html
[GitHub releases]: https://github.com/AaronLasseigne/unifig/releases
[API Documentation]: http://rubydoc.info/github/AaronLasseigne/unifig
[our contribution guidelines]: CONTRIBUTING.md
[unifig-env]: https://github.com/AaronLasseigne/unifig-env
[complete list of contributors]: https://github.com/AaronLasseigne/unifig/graphs/contributors
[the MIT License]: LICENSE.txt
