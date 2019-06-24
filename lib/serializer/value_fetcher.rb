class ValueFetcher
  class SerializerError < StandardError; end

  ARRAYS = %w[
    Array
    ActiveRecord_AssociationRelation
    ActiveRecord_Associations_CollectionProxy
  ].freeze

  def self.fetch(attribute, object, serializer)
    new(attribute, object, serializer).fetch
  end

  private_class_method :new

  def initialize(attribute, object, serializer)
    @attribute = attribute
    @values = [
      StaticValue.new(attribute),
      SerializedValue.new(attribute, serializer),
      HashValue.new(attribute, object),
      ObjectValue.new(attribute, object)
    ]
  end

  def fetch
    serializer = @attribute.serializer

    return value unless serializer

    if array?
      value.map { |item| serializer.new(item).to_h }
    else
      serializer.new(value).to_h
    end
  end

  # Fetches a value from an attribute by checking if there's a ..
  # .. static value set, or a ..
  # .. method defined in the serializer, or a ..
  # .. method/attribute defined in the object or ..
  # .. it raises an error
  def value
    @value ||= begin
      extracted_value = @values.detect(&:precondition?)

      if extracted_value.nil?
        raise SerializerError,
              "unknown attribute '#{@values[0].extraction_key}'"
      end

      extracted_value.value
    end
  end

  def array?
    ARRAYS.any? { |match| value.class.to_s.end_with?(match) }
  end
end
