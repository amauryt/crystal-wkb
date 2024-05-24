require "./bin_decoder"

module WKB
  module DB
    {% for kind in %w[
      Object
      Geometry
      Point
      LineString
      Polygon
      MultiPoint
      MultiLineString
      MultiPolygon
      GeometryCollection
    ] %}
      module {{kind.id}}Converter
        @@decoder = WKB::BinDecoder.new

        def self.from_rs(rs : ::DB::ResultSet)
          @@decoder.decode(rs.read(Bytes)).as(WKB::{{kind.id}})
        end
      end
    {% end %}
  end
end
