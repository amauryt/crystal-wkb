require "string_scanner"
require "./flavor"
require "./mode"

module WKB
  # Textual decoder of well-known representations of geometry objects (WKT).
  #
  # WARNING: Decoding of EWKT with 3D and 4D coordinates is not supported.
  #
  # NOTE: All `#decode` metods raise  a `WKB::Error` if there was a
  # decoding error or if the geometry object is not valid.
  class TextDecoder
    getter default_srid : Int32
    @mutex = Mutex.new
    @scanner = StringScanner.new("")
    @current_mode = Mode::XY
    @current_srid = 0
    @current_token : String | Delimiter | Float64 | Nil

    private enum Delimiter : UInt8
      Empty
      Open
      Close
      Comma
    end

    def initialize(@default_srid = 0)
    end

    def decode(str : String) : Object
      @mutex.synchronize do
        str = str.downcase
        @scanner = StringScanner.new(str)
        @current_mode = Mode::XY
        @current_srid = @default_srid
        if srid_match = /^srid=(\d+);/.match(str)
          @current_srid = srid_match[1].to_i32
          @scanner.offset = srid_match.end
        else
          @current_srid = @default_srid
        end
        next_token
        read_single_object
      end
    end

    private def read_single_object
      expect_token_type(String)
      begin
        type = ObjectKind.parse(@current_token.to_s)
      rescue ArgumentError
        raise WKB::DecodeError.new("Unsupported geometry: #{@current_token.to_s.upcase}.")
      end
      next_token
      unless empty?
        case @current_token
        when "z"
          @current_mode = Mode::XYZ
          next_token
        when "zm"
          @current_mode = Mode::XYZM
          next_token
        when "m"
          @current_mode = Mode::XYM
          next_token
        end
      end
      case type
      in .point?
        slice = if empty?
                  Position.new(Slice(Float64).empty, @current_mode)
                else
                  read_enclosed_position
                end
        Point.new(slice, @current_mode, @current_srid)
      in .line_string?
        create_geom_from LineString, Position
      in .polygon?
        create_geom_from Polygon, LineString
      in .multi_point?
        create_geom_from MultiPoint, Point
      in .multi_line_string?
        create_geom_from MultiLineString, LineString
      in .multi_polygon?
        create_geom_from MultiPolygon, Polygon
      in .geometry_collection?
        create_geom_from GeometryCollection, Geometry
      end
    end

    private def next_token
      if token = @scanner.scan_until(/\(|\)|,|[^\s()\[\],]+/)
        token = token.lstrip
        case token
        when /^[-+]?(\d+(\.\d*)?|\.\d+)(e[-+]?\d+)?$/
          @current_token = Float64.new(token)
        when "empty"
          @current_token = Delimiter::Empty
        when /^[a-z]+$/
          @current_token = token
        when ","
          @current_token = Delimiter::Comma
        when "("
          @current_token = Delimiter::Open
        when ")"
          @current_token = Delimiter::Close
        else
          raise WKB::DecodeError.new("Bad token: #{token.inspect}")
        end
      else
        @current_token = nil
      end
    end

    private def expect_token_type(type)
      unless type === @current_token
        raise WKB::DecodeError.new("#{type.inspect} expected but #{@current_token.inspect} found.")
      end
    end

    private def read_position : Position
      slice = Slice(Float64).new(@current_mode.size) do
        next_token
        expect_token_type(Float64)
        @current_token.not_nil!.to_f64
      end
      Position.new(slice, @current_mode)
    end

    private def read_enclosed_position : Position
      expect_token_type(Delimiter::Open)
      position = read_position
      next_token
      expect_token_type(Delimiter::Close)
      position
    end

    private def read_enclosed_positions : Array(Position)
      expect_token_type(Delimiter::Open)
      positions = [] of Position
      loop do
        positions << read_position
        check_close_or_comma
      end
      positions
    end

    private def read_enclosed_geometries
      expect_token_type(Delimiter::Open)
      geometries = [] of Geometry
      next_token
      loop do
        geometries << read_single_object.as(Geometry)
        check_close_or_comma
        next_token
      end
      geometries
    end

    private macro def_read_multi_enclosed(klass, read_base_method)
      {% objects = "#{klass.id.underscore}s".id %}
      private def read_enclosed_{{objects}} : Array({{klass}})
        expect_token_type(Delimiter::Open)
        {{objects}} = [] of {{klass}}
        next_token
        loop do 
          {{objects}} << {{klass}}.new({{read_base_method.id}}, @current_mode, @current_srid)
          check_close_or_comma_and_open
        end
        {{objects}}
      end
    end

    private macro create_geom_from(klass, child_klass)
      {% if child_klass.id == "Geometry" %}
        {% children = "geometries".id %}
      {% else %}
        {% children = "#{child_klass.id.underscore}s".id %}
      {% end %}
      {{children}} = empty? ? [] of {{child_klass}} : read_enclosed_{{children}}
      {{klass}}.new({{children}}, @current_mode, @current_srid)
    end

    def_read_multi_enclosed Point, read_enclosed_position
    def_read_multi_enclosed Polygon, read_enclosed_line_strings
    def_read_multi_enclosed LineString, read_enclosed_positions

    private macro empty?
      @current_token == Delimiter::Empty
    end

    private macro check_close_or_comma
      next_token
      break if @current_token == Delimiter::Close
      expect_token_type(Delimiter::Comma)
    end

    private macro check_close_or_comma_and_open
      check_close_or_comma
      next_token
      expect_token_type(Delimiter::Open)
    end
  end
end
