class GroupSerializer
  def initialize(objects, serializer: nil)
    raise ArgumentError, 'serializer needs to be specified' if serializer.nil?

    @objects = objects
    @serializer = serializer
  end

  def to_json(*)
    Appsignal.instrument(
      'json.serialize',
      'Group serializer',
      @serializer.to_s
    ) do
      result = @objects.map { |object| @serializer.new(object).to_h }

      Oj.dump(result, mode: :json)
    end
  end
end
