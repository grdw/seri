require 'serializer/version'
require 'serializer/group_serializer'

class Serializer
  class SerializerError < StandardError; end

  Attribute = Struct.new(:key, :condition, :from, :options)

  def self.attributes
    @attributes ||= []
  end

  def self.attribute(key, condition: nil, from: nil, **options)
    attributes.push(Attribute.new(key, condition, from, options))
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

      extraction_key = attribute.from || attribute.key

      # Fetches a value from an attribute by checking if there's a ..
      # .. static value set, or a ..
      # .. method defined in the serializer, or a ..
      # .. method/attribute defined in the object or ..
      # .. it raises an error
      value = if attribute.options.has_key?(:static_value)
                attribute.options.fetch(:static_value)
              elsif respond_to?(extraction_key)
                public_send(extraction_key)
              elsif object.respond_to?(extraction_key)
                object.public_send(extraction_key)
              else
                raise SerializerError, "unknown attribute '#{extraction_key}'"
              end

      obj[attribute.key] = value
    end
  end

  def to_json(*)
    Appsignal.instrument(
      'serializer.serialize',
      'Serializer',
      self.class.to_s
    ) do
      Oj.dump(to_h, mode: :json)
    end
  end
end
