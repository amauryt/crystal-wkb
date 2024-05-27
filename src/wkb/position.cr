require "./mode"

module WKB
  # A position is the base entity to represent coordinates in geometry objects.
  #
  # Positions are a thin wrapper around a slice of double precision floats,
  # they have a mode, and they can also be empty.
  struct Position
    include Indexable(Float64)
    # Returns the underlying slice of coordinates.
    getter slice : Slice(Float64)
    # Returns the position's coordinate mode.
    getter mode = Mode::XY
    # :nodoc:
    delegate :unsafe_fetch, to: @slice

    protected def initialize(@slice, @mode)
      unless empty?
        if @slice.size != @mode.size
          message = "#{@mode} coordinates must have #{@mode.size} elements, not #{@slice.size}"
          raise WKB::Error.new(message)
        end
      end
    end

    # Creates a position with the given _coordinates_ (which can be empty) and coordinate _mode_.
    #
    # NOTE: It raises `WKB::Error` if the number of coordinates does not agree with the mode.
    def initialize(coordinates : Array(Float64), mode : Mode)
      slice = Slice(Float64).new(coordinates.size) { |i| coordinates[i] }
      initialize(slice, mode)
    end

    # Returns the X coordinate or `Float64::NAN` if empty.
    def x
      @slice.empty? ? Float64::NAN : @slice[0]
    end

    # Returns the Y coordinate or `Float64::NAN` if empty.
    def y
      @slice.empty? ? Float64::NAN : @slice[1]
    end

    # Returns the Z coordinate or `Float64::NAN` if empty or the mode has not Z.
    def z
      if @slice.empty? || !@mode.has_z?
        Float64::NAN
      else
        @slice[2]
      end
    end

    # Returns the M coordinate or `Float64::NAN` if empty or the mode has not M.
    def m
      if @slice.empty?
        Float64::NAN
      elsif @mode.xyzm?
        @slice[3]
      elsif @mode.xym?
        @slice[2]
      else
        Float64::NAN
      end
    end

    # Returns `true` if the Z coordinate is supported.
    def has_z?
      @mode.has_z?
    end

    # Returns `true` if the M coordinate is supported.
    def has_m?
      @mode.has_m?
    end

    # Returns `true` if both Z and M coordinates are supported.
    def has_zm?
      @mode.has_zm?
    end

    # Returns the number of coordinates.
    def size
      @slice.size
    end

    # Returns a representation of coordinates as an array.
    def to_coordinates : Array(Float64)
      @slice.to_a
    end
  end
end
