class Value
  def initialize(attribute, scope = nil)
    @attribute = attribute
    @scope = scope
  end

  def extraction_key
    @attribute.from || @attribute.key
  end

  def precondition?
    raise NotImplementedError, 'needs a method called precondition?'
  end

  def value
    raise NotImplementedError, 'needs a method called value'
  end
end

class StaticValue < Value
  def precondition?
    @attribute.options.key?(:static_value)
  end

  def value
    @attribute.options.fetch(:static_value)
  end
end

class SerializedValue < Value
  def precondition?
    @scope.respond_to?(extraction_key)
  end

  def value
    @scope.public_send(extraction_key)
  end
end

class HashValue < Value
  def precondition?
    @scope.is_a?(Hash) && @scope.key?(extraction_key)
  end

  def value
    @scope.fetch(extraction_key)
  end
end

class ObjectValue < Value
  def precondition?
    @scope.respond_to?(extraction_key)
  end

  def value
    @scope.public_send(extraction_key)
  end
end
