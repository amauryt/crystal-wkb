require "./flavor"
require "./mode"

module WKB
  class TextEncoder
    getter flavor : Flavor

    def initialize(@flavor = Flavor::Basic)
    end

    def encode(object : Object, io : IO) : Nil
      write_single_object(object, io)
    end

    def encode(object : Object) : String
      String.build do |io|
        write_single_object(object, io)
      end
    end

    private def write_single_object(object : Object, io : IO)
      io << "SRID=#{object.srid};" if @flavor.ext_srid?
      object.kind.to_s.upcase(io)

      case @flavor
      in .basic?
        unless object.mode.xy?
          raise WKB::EncodeError.new("#{@flavor} flavor cannot be used with mode #{object.mode}")
        end
      in .ext?, .ext_srid?
        io << "M" if object.mode.has_m?
      in .iso?
        case object.mode
        when .xyz?
          io << " Z"
        when .xyzm?
          io << " ZM"
        when .xym?
          io << " M"
        end
      end

      if object.empty?
        io << " EMPTY"
      else
        case object
        when Point
          point = object
          join_point_position
        when LineString
          als = object.positions
          join_array_line_string
        when Polygon, MultiLineString
          amls = object.line_strings.map(&.positions)
          join_array_multiple_line_strings
        when MultiPoint
          parens_start
          object.points.each do |point|
            join_point_position
            comma
          end
          parens_end
        when MultiPolygon
          parens_start
          object.polygons.each do |polygon|
            amls = polygon.line_strings.map(&.positions)
            join_array_multiple_line_strings
            comma
          end
          parens_end
        when GeometryCollection
          parens_start
          object.geometries.each do |geometry|
            write_single_object(geometry, io)
            comma
          end
          parens_end
        end
      end
    end

    private macro parens_start
      io << '('
    end

    private macro comma
      io << ", "
    end

    private macro parens_end
      io.back(2) # overwrite last comma and space
      io << ')'
    end

    private macro join_point_position
      io << '('
      point.position.join(io, ' ')
      io << ')'
    end

    private macro join_array_line_string
      parens_start
      als.each do |s|
        s.join(io, ' ')
        comma
      end
      parens_end
    end

    private macro join_array_multiple_line_strings
      parens_start
      amls.each do |als|
        join_array_line_string
        comma
      end
      parens_end
    end
  end
end
