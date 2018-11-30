# Seri

[![CircleCI](https://circleci.com/gh/grdw/serializer.svg?style=svg)](https://circleci.com/gh/grdw/serializer)

A basic replacement for gems like `active_model_serializers`. Can turn any
basic Ruby object into a Hash or JSON string with features like:

- Aliasing attribute keys
- Overriding attributes
- Setting static values
- Creating conditional attributes

See [usage](#usage) for more details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seri'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seri

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
  attribute :some_method
  attribute :some_conditional_method, condition: :a_condition
  attribute :some_other_conditional_method, condition: :b_condition

  def some_method
    object.mileage * 25
  end

  def brand
    'mercedes'
  end

  def some_conditional_method
    'visible condition'
  end

  def a_condition
    true
  end

  def some_other_conditional_method
    'non visible condition'
  end

  def b_condition
    !a_condition
  end
end

# example implementation:
car = Car.new
car.mileage = 25

serializer = CarSerializer.new(car)
serializer.to_json
```

Result from `#to_json`:

```json
{
  "mileage": 25,
  "brand": "mercedes",
  "mileage_alias": 25,
  "honk": "honk_honk",
  "some_method": "625",
  "some_conditional_method": "visible_condition"
}
```

In turn there's also a `GroupSerializer` available which can take a group of
cars and turn them into a serialized Array. If we extend the example from
earlier we can do:

```ruby
# example:
cars = [car, car]
group_serializer = GroupSerializer.new(cars, serializer: CarSerializer)

group_serializer.to_json
```

Result from `#to_json`:

```json
[
  {
    "mileage": 25,
    "brand": "mercedes",
    "mileage_alias": 25,
    "honk": "honk_honk",
    "some_method": "625",
    "some_conditional_method": "visible_condition"
  },
  {
    "mileage": 25,
    "brand": "mercedes",
    "mileage_alias": 25,
    "honk": "honk_honk",
    "some_method": "625",
    "some_conditional_method": "visible_condition"
  }
]
```

## Q&A

**Q: This looks cool and all but how do I do a `has_many`?**

Answer:

```ruby
class A
  attr_accessor :some_amazing_attribute
end

class B
  attr_accessor :some_attribute

  def aaa
    [A.new, A.new, A.new]
  end
end

class ASerializer < Serializer
  attribute :some_amazing_attribute
end

class BSerializer < Serializer
  attribute :lots_of_a, from: :aaa, serializer: ASerializer
end
```

The result from `BSerializer.new(b)#to_json`:

```json
{
  "lots_of_a": [
    { "some_amazing_attribute": null },
    { "some_amazing_attribute": null },
    { "some_amazing_attribute": null }
  ]
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/grdw/serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Serializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/grdw/seri/blob/master/CODE_OF_CONDUCT.md).
