class GroupSerializer
  def initialize(objects, serializer: nil, scope: {})
    raise ArgumentError, 'serializer needs to be specified' if serializer.nil?

    @objects = objects
    @serializer = serializer
    @scope = scope
  end

  def to_json(*)
    Appsignal.instrument(
      'json.serialize',
      'Group serializer',
      @serializer.to_s
    ) do
      Oj.dump(to_h, mode: :json)
    end
  end

  def to_h
    @objects
      .map { |object| @serializer.new(object, scope: @scope) }
      .map(&:to_h)
  end
end
