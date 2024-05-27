require "./geometry"
require "./line_string"

module WKB
  module LineStringSequenceable
    getter line_strings : Array(LineString)

    protected def initialize(@line_strings : Array(LineString), @mode, @srid)
      validate_initialization
    end

    def initialize(line_array : Array(Array(Array(Float64))), mode = Mode::XY, srid = 0)
      lines = if line_array.empty?
                Array(LineString).new
              else
                line_array.map do |coordinates_array|
                  LineString.new(coordinates_array, mode, srid)
                end
              end
      initialize(lines, mode, srid)
    end

    def children
      @line_strings
    end

    def size
      @line_strings.size
    end

    def empty?
      @line_strings.empty?
    end

    def to_coordinates : Array(Array(Array(Float64)))
      @line_strings.map do |line_string|
        line_string.positions.map(&.to_a)
      end
    end
  end
end
