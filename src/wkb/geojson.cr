require "json"

module WKB
  protected def self.mode_from_json_coord_elements(elements, pull : JSON::PullParser) : Mode
    if elements.size == 2 || elements.size.zero?
      Mode::XY
    elsif elements.size == 3
      Mode::XYZ
    elsif elements.size == 1
      pull.raise("Coordinates cannot have a single element.")
    else
      pull.raise("Coordinates cannot more than three elements")
    end
  end

  struct Position
    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    def self.new(pull : JSON::PullParser)
      coordinates = Array(Float64).new(pull)
      mode = WKB.mode_from_json_coord_elements(coordinates, pull)
      Position.new(coordinates, mode)
    end

    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    def to_json(builder : JSON::Builder)
      builder.array do
        slice.each { |f| builder.number f }
      end
    end
  end

  abstract struct Object
    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    abstract def to_json(builder : JSON::Builder)

    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    def self.new(pull : JSON::PullParser)
      # NOTE: if the first coordinates element is empty and the second not and the latter is XYZ it will raise an error
      pull.read_begin_object
      pull.read_object_key
      type = pull.read_string
      begin
        kind = ObjectKind.parse(type)
      rescue ArgumentError
        pull.raise "WKB does not support object type '#{type}'."
      end
      mode = Mode::XY
      case kind
      when .geometry?
        if pull.read_object_key != "coordinates"
          pull.raise "Geometry must have a 'coordinates' object key."
        end
        case kind
        when .point?
          coordinates = Array(Float64).new(pull)
          mode = WKB.mode_from_json_coord_elements(coordinates, pull) unless coordinates.empty?
          object = Point.new(coordinates, mode)
        when .line_string?, .multi_point?
          coordinates = Array(Array(Float64)).new(pull)
          mode = WKB.mode_from_json_coord_elements(coordinates.first, pull) unless coordinates.empty?
          object = kind.line_string? ? LineString.new(coordinates, mode) : MultiPoint.new(coordinates, mode)
        when .polygon?, .multi_line_string?
          coordinates = Array(Array(Array(Float64))).new(pull)
          mode = WKB.mode_from_json_coord_elements(coordinates.first.first, pull) unless coordinates.empty?
          object = kind.multi_line_string? ? MultiLineString.new(coordinates, mode) : Polygon.new(coordinates, mode)
        when .multi_polygon?
          coordinates = Array(Array(Array(Array(Float64)))).new(pull)
          mode = WKB.mode_from_json_coord_elements(coordinates.first.first.first, pull) unless coordinates.empty?
          object = MultiPolygon.new(coordinates, mode)
        else
          raise "Unreachable code!"
        end
      when .geometry_collection?
        if pull.read_object_key != "geometries"
          pull.raise "Geometry Collection must have a 'geometries' object key."
        end
        geometries = Array(Geometry).new(pull)
        mode = geometries.first.mode unless geometries.empty?
        object = GeometryCollection.new(geometries, mode)
      else
        raise "Unreachable code!"
      end
      pull.read_end_object
      object
    end
  end

  abstract struct Geometry
    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    def to_json(builder : JSON::Builder) : Nil
      builder.object do
        builder.string "type"
        builder.string kind.to_s
        builder.string "coordinates"
        if self.is_a?(Point)
          self.position.to_json(builder)
        elsif self.is_a?(LineString)
          builder.array do
            self.positions.each { |p| p.to_json(builder) }
          end
        elsif self.is_a?(Polygon) || self.is_a?(MultiLineString)
          builder.array do
            self.line_strings.each do |line_string|
              builder.array do
                line_string.positions.each { |p| p.to_json(builder) }
              end
            end
          end
        elsif self.is_a?(MultiPoint)
          builder.array do
            self.points.each do |point|
              point.position.to_json(builder)
            end
          end
        elsif self.is_a?(MultiPolygon)
          builder.array do
            self.polygons.each do |polygon|
              builder.array do
                polygon.line_strings.each do |line_string|
                  builder.array do
                    line_string.positions.each { |p| p.to_json(builder) }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  struct GeometryCollection
    # NOTE: It's necessary to require the GeoJSON extension after loading the library.
    def to_json(builder : JSON::Builder) : Nil
      builder.object do
        builder.string "type"
        builder.string kind.to_s
        builder.string "geometries"
        geometries.to_json(builder)
      end
    end
  end

  {% for klass in %w[Point LineString Polygon MultiPoint MultiLineString MultiPolygon Geometry GeometryCollection] %}
    struct {{klass.id}}
      # NOTE: It's necessary to require the GeoJSON extension after loading the library.
      def self.new(pull : JSON::PullParser)
        Object.new(pull).as({{klass.id}})
      end
    end
  {% end %}
end
