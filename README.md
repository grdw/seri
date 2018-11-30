# Serializer

A basic replacement for gems like `active_model_serializers`. Can turn any
basic Ruby object into a Hash or JSON string with features like:

- Aliasing attribute keys
- Overriding attributes
- Setting static values

See [usage](#usage) for more details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serializer

## Usage

A serializer can be used as such:

```ruby
# example class:
class Car
  attr_accessor :mileage
end

# example serializer:
class CarSerializer < Serializer
  attribute :mileage
  attribute :brand
  attribute :mileage_alias, from: :mileage
  attribute :honk, static_value: 'honk honk'

  def brand
    'mercedes'
  end
end

# example implementation:
car = Car.new
car.mileage = 25

serializer = CarSerializer.new(car)
serializer.to_h
serializer.to_json
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Serializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/serializer/blob/master/CODE_OF_CONDUCT.md).
