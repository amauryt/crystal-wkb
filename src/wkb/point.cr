require "./geometry"
require "./position"

module WKB
  struct Point < Geometry
    # Returns the point's underlying position.
    getter position : Position

    protected def initialize(@position, @mode, @srid)
    end

    def initialize(coordinates : Array(Float64), mode = Mode::XY, srid = 0)
      slice = Slice(Float64).new(coordinates.size) { |i| coordinates[i] }
      initialize(Position.new(slice, mode), mode, srid)
    end

    # Returns the X coordinate or `Float64::NAN` if empty.
    def x
      @position.x
    end

    # Returns the Y coordinate or `Float64::NAN` if empty.
    def y
      @position.y
    end

    # Returns the Z coordinate or `Float64::NAN` if empty or the mode has not Z.
    def z
      @position.z
    end

    # Returns the M coordinate or `Float64::NAN` if empty or the mode has not M.
    def m
      @position.m
    end

    # Returns an array with the point's position or an empty array if the position is empty.
    def children
      @position.empty? ? [] of Position : [@position]
    end

    # Returns `true` if the point's position is empty.
    def empty?
      @position.empty?
    end

    # Returns `0` if the point's position is empty, `1` otherwise.
    def size
      @position.empty? ? 0 : 1
    end

    # Returns a representation of coordinates as an array.
    def to_coordinates
      @position.to_coordinates
    end
  end
end
