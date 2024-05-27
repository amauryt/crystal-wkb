require "./point"

module WKB
  struct LineString < Geometry
    include Indexable(Position)

    getter positions : Array(Position)
    # :nodoc:
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

    def size
      @positions.size
    end

    def empty?
      @positions.empty?
    end

    def to_coordinates : Array(Array(Float64))
      @positions.map(&.to_a)
    end

    # Returns `true` if empty or the first child position is equal to the last one.
    def closed?
      @positions.empty? || @positions.first == @positions.last
    end

    # Returns the opposite of `#closed?`.
    def open?
      !closed?
    end

    # Returns `true` if there are at least four positions and they are `#closed?`.
    def ring?
      @positions.size >= 4 && @positions.first == @positions.last
    end
  end
end
