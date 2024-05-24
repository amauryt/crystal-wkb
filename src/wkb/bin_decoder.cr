require "./mode"

module WKB
  class BinDecoder
    @io = IO::Memory.new(0)
    @mutex = Mutex.new
    @main_mode = Mode::XY
    @main_srid = 0
    @main_children_count = 0
    @format : IO::ByteFormat = IO::ByteFormat::LittleEndian

    getter default_srid

    def initialize(@default_srid = 0)
    end

    def decode(io : IO) : Object
      @mutex.synchronize do
        @io = io
        # reset
        @main_mode = Mode::XY
        @main_srid = 0
        @main_children_count = 0
        read_single_object(nil)
      end
    rescue ex : IO::Error
      raise WKB::DecodeError.new(ex.message)
    end

    def decode(data : Bytes) : Object
      decode(IO::Memory.new(data, writable = false))
    end

    def decode(data : String) : Object
      decode data.hexbytes
    end

    private macro read_single_object_as(type)
      {% if type.id == "Geometry" %}
        read_single_object(ObjectKind::GeometryCollection).as(Geometry)
      {% else %}
        read_single_object(ObjectKind::{{type.id}}).as({{type.id}})
      {% end %}
    end

    private def byte_format_for(byte : UInt8)
      if byte == 1_u8
        IO::ByteFormat::LittleEndian
      elsif byte = 0_u8
        IO::ByteFormat::BigEndian
      else
        raise WKB::DecodeError.new("Invalid endianness #{byte}")
      end
    end

    private def read_child_count
      @io.read_bytes(UInt32, @format)
    end

    private def read_coordinate
      @io.read_bytes(Float64, @format)
    end

    private def read_line_string : LineString
      positions = [] of Position
      read_child_count.times do
        slice = Slice(Float64).new(@main_mode.size) { read_coordinate }
        positions << Position.new(slice, @main_mode)
      end
      LineString.new(positions, @main_mode, @main_srid)
    end

    private def read_single_object(expected_kind : ObjectKind?)
      @format = byte_format_for(@io.read_bytes(UInt8))
      type_data = @io.read_bytes(UInt32, @format)

      has_z = false
      has_m = false
      has_srid = false
      srid = @default_srid
      mode = @main_mode

      if type_data < 1000 # Basic WKB
        kind = ObjectKind.new(type_data)
      else # Non-basic WKB
        # Ext and ExtSRID flavors
        has_z = type_data & 0x80000000 != 0
        has_m = type_data & 0x40000000 != 0
        has_srid = type_data & 0x20000000 != 0
        srid = @io.read_bytes(UInt32, @format).to_i32 if has_srid
        if has_z || has_m || has_srid
          kind = ObjectKind.new(type_data & 0x0fffffff)
        else
          # ISO flavor
          has_z = (type_data // 1000) & 1 != 0
          has_m = (type_data // 1000) & 2 != 0
          kind = ObjectKind.new(type_data % 1000)
        end
        if has_m && has_z
          mode = Mode::XYZM
        elsif has_z
          mode = Mode::XYZ
        elsif has_m
          mode = Mode::XYM
        end
      end
      if expected_kind.nil?
        @main_mode = mode
        @main_srid = srid
      else
        if expected_kind != kind && expected_kind.geometry?
          raise WKB::DecodeError.new("Child geometry has type #{kind} but expected #{expected_kind}")
        end
        if @main_mode != mode
          raise WKB::DecodeError.new("Child geometry has #{mode} but expected #{@main_mode}")
        end
        if @main_srid != srid
          raise WKB::DecodeError.new("Child geometry has SRID #{srid} but expected SRID #{@main_srid}")
        end
      end

      case kind
      when .point?
        slice = Slice(Float64).new(@main_mode.size) { read_coordinate }
        slice = Slice(Float64).empty if slice.any?(&.nan?)
        Point.new(Position.new(slice, @main_mode), @main_mode, @main_srid)
      when .line_string?
        read_line_string
      when .polygon?
        line_strings = read_child_count.times.map { read_line_string }.to_a
        Polygon.new(line_strings, @main_mode, @main_srid)
      when .multi_point?
        points = read_child_count.times.map { read_single_object_as(Point) }.to_a
        MultiPoint.new(points, @main_mode, @main_srid)
      when .multi_line_string?
        line_strings = read_child_count.times.map { read_single_object_as(LineString) }.to_a
        MultiLineString.new(line_strings, @main_mode, @main_srid)
      when .multi_polygon?
        polygons = read_child_count.times.map { read_single_object_as(Polygon) }.to_a
        MultiPolygon.new(polygons, @main_mode, @main_srid)
      when .geometry_collection?
        geometries = read_child_count.times.map { read_single_object_as(Geometry) }.to_a
        GeometryCollection.new(geometries, @main_mode, @main_srid)
      else
        raise WKB::DecodeError.new("Unsupported geometry: #{kind}.")
      end
    end
  end
end
