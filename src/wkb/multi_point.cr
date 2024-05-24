require "./point"

module WKB
  struct MultiPoint < Geometry
    getter points : Array(Point)
    delegate :empty?, to: @points
    delegate :size, to: @points

    protected def initialize(@points : Array(Point), @mode, @srid)
    end

    def initialize(point_array : Array(Array(Float64)), mode = Mode::XY, srid = 0)
      points = if point_array.empty?
                 Array(Point).new
               else
                 point_array.map do |coordinates_array|
                   Point.new(coordinates_array, mode, srid)
                 end
               end
      initialize(points, mode, srid)
    end

    def children
      @points
    end

    def to_coordinates : Array(Array(Float64))
      @points.map(&.to_coordinates)
    end
  end
end
