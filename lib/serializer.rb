require 'serializer/version'
require 'serializer/value'
require 'serializer/value_fetcher'
require 'serializer/group_serializer'

class Serializer
  Attribute = Struct.new(:key, :condition, :from, :serializer, :options)

  def self.attributes
    @attributes ||= []
  end

  def self.attribute(key, condition: nil, from: nil, serializer: nil, **options)
    attributes.push(Attribute.new(key, condition, from, serializer, options))
  end

  attr_accessor :object, :scope

  def initialize(object, scope: {})
    @object = object
    @scope = scope
  end

  # Loops over all attributes and skips if a condition is defined and falsey
  def to_h
    self.class.attributes.each_with_object({}) do |attribute, obj|
      next if attribute.condition && !public_send(attribute.condition)

      obj[attribute.key] = ValueFetcher.fetch(attribute, object, self)
    end
  end

  def to_json(*)
    Oj.dump(to_h, mode: :json)
  end
end
