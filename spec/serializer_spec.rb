require 'spec_helper'

RSpec.describe Serializer do
  class Car
    attr_accessor :mileage, :brand

    def doors
      [
        Door.new(:front_left),
        Door.new(:front_right),
        Door.new(:back_left),
        Door.new(:back_right)
      ]
    end
  end

  class Door
    attr_accessor :position

    def initialize(position)
      @position = position
    end
  end

  describe 'group serialization' do
    let(:cars) do
      car_one = Car.new
      car_one.mileage = 20

      car_two = Car.new
      car_two.mileage = 30

      [car_one, car_two]
    end

    context 'easy case' do
      class OneToOneCarSerializer < Serializer
        attribute :mileage
      end

      it 'can dump multiple cars' do
        result = GroupSerializer.new(
          cars,
          serializer: OneToOneCarSerializer
        ).to_h

        expect(result).to eq(
          [
            { mileage: 20 },
            { mileage: 30 }
          ]
        )
      end
    end

    context 'easy case with scope' do
      class CarScopedSerializer < Serializer
        attribute :mileage
        attribute :scoped_value

        def scoped_value
          scope[:scope_value] * 5
        end
      end

      it 'can dump multiple cars' do
        result = GroupSerializer.new(
          cars,
          serializer: CarScopedSerializer,
          scope: { scope_value: 2 }
        ).to_h

        expect(result).to eq(
          [
            { mileage: 20, scoped_value: 10 },
            { mileage: 30, scoped_value: 10 }
          ]
        )
      end
    end
  end

  describe '#to_h' do
    let(:car) do
      car = Car.new
      car.mileage = 25
      car
    end

    describe 'hash aliasing' do
      class HashSerializer < Serializer
        attribute :a, from: :b
        attribute :b, from: :c
      end

      it 'a standard hash' do
        serializer = HashSerializer.new(b: 25, c: 35)

        expect(serializer.to_h).to eq(a: 25, b: 35)
      end
    end

    describe 'one-to-one attribute' do
      class OneToOneCarSerializerWithItems < Serializer
        attribute :mileage
        attribute :items

        def items
          %w[1 2 3]
        end
      end

      it 'dumps the mileage' do
        car_serializer = OneToOneCarSerializerWithItems.new(car)
        serialized = car_serializer.to_h

        expect(serialized.fetch(:mileage)).to eq(25)
        expect(serialized.fetch(:items)).to eq(%w[1 2 3])
      end
    end

    describe 'method overriding' do
      class OverrideCarSerializer < Serializer
        attribute :mileage

        def mileage
          55
        end
      end

      it 'dumps the mileage' do
        car_serializer = OverrideCarSerializer.new(car)
        serialized = car_serializer.to_h

        expect(serialized.fetch(:mileage)).to eq(55)
      end
    end

    describe 'aliasing' do
      class AliasCarSerializer < Serializer
        attribute :miles_to_the_gallon, from: :mileage
      end

      it 'dumps the mileage' do
        car_serializer = AliasCarSerializer.new(car)
        serialized = car_serializer.to_h

        expect(serialized.fetch(:miles_to_the_gallon)).to eq(25)
      end
    end

    describe 'static value' do
      class StaticValueCarSerializer < Serializer
        attribute :static, static_value: 5
      end

      it 'dumps the static value' do
        car_serializer = StaticValueCarSerializer.new(car)
        serialized = car_serializer.to_h

        expect(serialized.fetch(:static)).to eq(5)
      end
    end

    describe 'conditional keys' do
      class ConditionalCarSerializer < Serializer
        attribute :green_car, condition: :mileage_low?
        attribute :gas_slurper, condition: :mileage_high?

        def green_car
          'I am a green car'
        end

        def gas_slurper
          'I am a gas slurper'
        end

        def mileage_low?
          object.mileage < 20
        end

        def mileage_high?
          object.mileage >= 20
        end
      end

      it 'has the correct keys' do
        car_serializer = ConditionalCarSerializer.new(car)
        serialized = car_serializer.to_h

        expect(serialized).to_not have_key(:green_car)
        expect(serialized).to have_key(:gas_slurper)
      end
    end

    describe 'serialize-ception' do
      class DoorSerializer < Serializer
        attribute :pos, from: :position
      end

      class CarWithDoorsSerializer < Serializer
        attribute :fancy_doors, from: :doors, serializer: DoorSerializer
      end

      it 'has the correct keys' do
        car_serializer = CarWithDoorsSerializer.new(car)
        serialized = car_serializer.to_h

        expect(serialized.fetch(:fancy_doors)).to eq(
          [
            { pos: :front_left },
            { pos: :front_right },
            { pos: :back_left },
            { pos: :back_right }
          ]
        )
      end
    end

    describe 'unknown key' do
      class UnknownKeyCarSerializer < Serializer
        attribute :altitude
      end

      it 'raises an error' do
        car_serializer = UnknownKeyCarSerializer.new(car)
        expect { car_serializer.to_h }.to raise_error(
          ValueFetcher::SerializerError,
          /unknown attribute 'altitude'/
        )
      end
    end
  end
end
