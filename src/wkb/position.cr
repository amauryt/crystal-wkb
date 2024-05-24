require "./mode"

module WKB
  struct Position
    include Indexable(Float64)

    getter slice : Slice(Float64)
    getter mode = Mode::XY
    delegate :size, to: @slice
    delegate :unsafe_fetch, to: @slice
    delegate :has_z?, to: @mode
    delegate :has_m?, to: @mode
    delegate :has_zm?, to: @mode

    protected def initialize(@slice, @mode)
      unless empty?
        if @slice.size != @mode.size
          message = "#{@mode} coordinates must have #{@mode.size} elements, not #{@slice.size}"
          raise WKB::Error.new(message)
        end
      end
    end

    def initialize(coordinates : Array(Float64), mode : Mode)
      slice = Slice(Float64).new(coordinates.size) { |i| coordinates[i] }
      initialize(slice, mode)
    end

    def x
      @slice.empty? ? Float64::NAN : @slice[0]
    end

    def y
      @slice.empty? ? Float64::NAN : @slice[1]
    end

    def z
      if @slice.empty? || !@mode.has_z?
        Float64::NAN
      else
        @slice[2]
      end
    end

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

    def to_coordinates : Array(Float64)
      @slice.to_a
    end
  end
end
