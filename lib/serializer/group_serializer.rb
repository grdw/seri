module Seri
  class GroupSerializer
    def initialize(objects, serializer: nil, scope: {})
      raise ArgumentError, 'serializer needs to be specified' if serializer.nil?

      @objects = objects
      @serializer = serializer
      @scope = scope
    end

    def to_json(*)
      Oj.dump(to_h, mode: :json)
    end

    def to_h
      @objects
        .map { |object| @serializer.new(object, scope: @scope) }
        .map(&:to_h)
    end
  end
end
