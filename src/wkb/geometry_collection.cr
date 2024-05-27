require "./object"

module WKB
  struct GeometryCollection < Object
    getter geometries : Array(Geometry)

    def initialize(@geometries : Array(Geometry), @mode = Mode::XY, @srid = 0)
      unless @geometries.empty?
        if @geometries.any? { |g| g.mode != @mode || g.srid != @srid }
          raise WKB::Error.new("All children of GeometryCollection must have mode #{@mode} and SRID #{@srid}")
        end
      end
    end

    def children
      @geometries
    end

    def size
      @geometries.size
    end

    def empty?
      @geometries.empty?
    end
  end
end
