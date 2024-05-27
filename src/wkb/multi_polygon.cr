require "./polygon"

module WKB
  struct MultiPolygon < Geometry
    getter polygons : Array(Polygon)

    protected def initialize(@polygons : Array(Polygon), @mode, @srid)
    end

    def initialize(lines_arrays : Array(Array(Array(Array(Float64)))), @mode = Mode::XY, @srid = 0)
      polygons = lines_arrays.map { |line_array| Polygon.new(line_array, @mode, @srid) }
      initialize(polygons, @mode, @srid)
    end

    def children
      @polygons
    end

    def size
      @polygons.size
    end

    def empty?
      @polygons.empty?
    end

    def to_coordinates : Array(Array(Array(Array(Float64))))
      @polygons.map(&.to_coordinates)
    end
  end
end
