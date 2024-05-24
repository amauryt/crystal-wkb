require "./point"

module WKB
  struct LineString < Geometry
    include Indexable(Position)

    getter positions : Array(Position)
    delegate :size, to: @positions
    delegate :unsafe_fetch, to: @positions

    protected def initialize(@positions : Array(Position), @mode, @srid)
      if @positions.any? { |position| position.size != @mode.size }
        raise WKB::Error.new("All coordinates must have #{@mode.size} elements each")
      end
    end

    def initialize(coordinates_array : Array(Array(Float64)), mode = Mode::XY, srid = 0)
      slices = if coordinates_array.empty?
                 [] of Position
               else
                 coordinates_array.map do |coordinates|
                   slice = Slice(Float64).new(coordinates.size) { |i| coordinates[i] }
                   Position.new(slice, mode)
                 end
               end
      initialize(slices, mode, srid)
    end

    def children
      @positions
    end

    def to_coordinates : Array(Array(Float64))
      @positions.map(&.to_a)
    end

    def closed?
      @positions.empty? || @positions.first == @positions.last
    end

    def open?
      !closed?
    end

    def ring?
      @positions.size >= 4 && @positions.first == @positions.last
    end
  end
end
