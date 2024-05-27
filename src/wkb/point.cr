require "./geometry"
require "./position"

module WKB
  struct Point < Geometry
    getter position : Position
    delegate :empty?, to: @position
    delegate :x, to: @position
    delegate :y, to: @position
    delegate :z, to: @position
    delegate :m, to: @position
    delegate :to_coordinates, to: @position

    protected def initialize(@position, @mode, @srid)
    end

    def initialize(coordinates : Array(Float64), mode = Mode::XY, srid = 0)
      slice = Slice(Float64).new(coordinates.size) { |i| coordinates[i] }
      initialize(Position.new(slice, mode), mode, srid)
    end

    def children
      @position.empty? ? [] of Position : [@position]
    end

    def size
      @position.empty? ? 0 : 1
    end
  end
end
