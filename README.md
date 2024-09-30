# Flip

Gem for

business.flip.id
flip.id
Big Flip

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flip'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install flip

## Usage

```ruby
    Flip.config.secret_key = ENV['FLIP_SECRET_KEY']
    Flip.config.valid_token = ENV['FLIP_VALID_TOKEN']
    flip_balance = Flip.balance
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ardianys/flip. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ardianys/flip/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Flip project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ardianys/flip/blob/master/CODE_OF_CONDUCT.md).
