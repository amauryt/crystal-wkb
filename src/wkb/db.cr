require "./bin_decoder"

module WKB
  # This module offers convenience converters when working with
  # `DB::Serializable` from [crystal-db](https://github.com/crystal-lang/crystal-db).
  #
  # Example:
  # ```
  # require "db"
  # require "my_db_driver"
  # require "wkb"
  # require "wkb/db"
  #
  # class MyClass
  #   include DB::Serializable
  #
  #   property name : String
  #
  #   @[DB::Field(converter: WKB::DB::ObjectConverter)]
  #   property geometry : WKB::Object
  # end
  # ```
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
