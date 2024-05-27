require "./mode"
require "./flavor"

module WKB
  # Binary encoder of well-known representations of geometry objects (WKB).
  class BinEncoder
    private macro write_coordinate_slice
      slice.each { |coordinate| io.write_bytes(coordinate, @format) }
    end

    getter flavor : Flavor
    getter format : IO::ByteFormat

    def initialize(@flavor = Flavor::Basic, @format = IO::ByteFormat::LittleEndian)
      @format_byte = @format == IO::ByteFormat::LittleEndian ? 1_u8 : 0_u8
    end

    def encode(object : Object, io : IO) : Nil
      io.write_byte @format_byte
      write_single_object(io, object)
    end

    def encode(object : Object) : Bytes
      io = IO::Memory.new
      io.write_byte @format_byte
      write_single_object(io, object)
      io.to_slice
    end

    private def write_single_object(io : IO, object : Object, include_type = true, include_format = false)
      include_srid = @flavor.ext_srid? && include_type && !include_format
      type_data = object.kind.value
      case @flavor
      in .basic?
        unless object.mode.xy?
          raise WKB::EncodeError.new("Flavor #{@flavor} cannot be used with mode #{object.mode}")
        end
      in .ext?, .ext_srid?
        type_data |= 0x80000000 if object.mode.has_z?
        type_data |= 0x40000000 if object.mode.has_m?
        type_data |= 0x20000000 if include_srid
      in .iso?
        type_data += 1000 if object.mode.has_z?
        type_data += 2000 if object.mode.has_m?
      end
      io.write_byte(@format_byte) if include_format
      io.write_bytes(type_data, @format) if include_type
      io.write_bytes(object.srid.to_u32, @format) if include_srid

      if object.is_a?(Point)
        if object.empty?
          object.mode.size.times { io.write_bytes(Float64::NAN, @format) }
        else
          object.position.each { |coord| io.write_bytes(coord, @format) }
        end
      else
        io.write_bytes(object.size.to_u32, @format)
        unless object.empty?
          case object
          when LineString
            object.positions.each do |slice|
              slice.each { |coord| io.write_bytes(coord, @format) }
            end
          when Polygon
            object.line_strings.each { |child| write_single_object(io, child, include_type: false) }
          when MultiLineString
            object.line_strings.each { |child| write_single_object(io, child, include_format: true) }
          when MultiPoint
            object.points.each { |child| write_single_object(io, child, include_format: true) }
          when MultiPolygon
            object.polygons.each { |child| write_single_object(io, child, include_format: true) }
          when GeometryCollection
            object.geometries.each { |child| write_single_object(io, child, include_format: true) }
          end
        end
      end
    end
  end
end
