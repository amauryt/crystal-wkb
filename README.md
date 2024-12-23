# Well-Known Binary in Crystal

[![Crystal CI](https://github.com/amauryt/crystal-wkb/actions/workflows/crystal.yml/badge.svg)](https://github.com/amauryt/crystal-wkb/actions/workflows/crystal.yml)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://amauryt.github.io/crystal-wkb/)
[![License](https://img.shields.io/github/license/amauryt/crystal-wkb.svg)](https://github.com/amauryt/crystal-wkb/blob/master/LICENSE)

Crystal library for decoding and encoding the well-known binary (WKB) representation of geometry objects, with limited support for well-known text (WKT) and GeoJSON.

This library supports the following variations of WKB used for storage of [simple features](https://en.wikipedia.org/wiki/Simple_Features) geometry:

 - Standard Well-Known Binary ([WKB](https://libgeos.org/specifications/wkb/#standard-wkb)): limited to XY
 - Extended Well-Known Binary ([EWKB](https://libgeos.org/specifications/wkb/#extended-wkb)) used by [PostGIS](https://postgis.net/): XY, XYZ, XYM, XYZM, with optional SRID
 - ISO 13249-3 Well-Known Binary ([ISO WKB](https://libgeos.org/specifications/wkb/#iso-wkb)): XY, XYZ, XYM, and XYZM

Only the following seven geometry objects are supported:

  1. Point
  2. LineString
  3. Polygon
  4. MultiPoint
  5. MultiLineString
  6. MultiPolygon
  7. GeometryCollection

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wkb:
       github: amauryt/crystal-wkb
   ```

2. Run `shards install`

3. Require the library

  ```crystal
    require "wkb"
   ```

### Coordinate Dimension Mode

The basic element to describe a geometry object is the _coordinate_, whose value is always of type `Float64` in WKB. Coordinates may be 2D (XY), 3D (XYZ, XYM) or 4D (XYZM). The struct `WKB::Position` is a thin wrapper around a `Slice(Float64)` instance to represent a set of coordinate elements. Each position and geometry object has a `WKB::Mode` enum to indicate one of the previous coordinate dimensions. This mode attribute is necessary to disambiguate 3D coordinates (which can be XYZ or XYM) in the methods and serialization of a position or geometry object, and it aids in checking the consistency of composite objects. The default mode is `WKB::Mode::XY`. Independently of their mode, a position and all seven geometry objects could be _empty_. 

### WKB Flavor

Variants of WKB and WKT serialization are referred to as _flavors_. The library represents these via the enum `WKB::Flavor`, with the possible values:

  - `Basic`: the default flavor, which follows Standard WKB and is limited to mode `XY`
  - `Ext`: for EWKB without SRID, usable with all four modes
  - `ExtSRID`: for EWKB with SRID, usable with all four modes
  - `ISO`: for ISO WKB, usable with all four modes

## Geometry Structs

Position and geomety objects SHOULD be considered to be immutable structures. All geometry objects can be directly created with (nested) arrays of `Float64, with the exception of geometry collection; see the examples below. In addition, all geometry objects need a mode (defaults to XY) and a SRID (defaults to 0, a value commonly used to signify that there is no SRID).

The main library's entitiy is the abstract struct `WKB::Object`, which represents one of the seven supported geometry objects. It has two descendants:

  - `WKB::Geometry`, an abstract struct that comprises the first six geometry objects
  - `WKB::GeometryCollection`, a special object to contain heterogeneous `WKB::Geometry` objects

All `WKB::Object` descendants have the following instance methods:

  - `#children` for the child elements of the geometry object, with each having a different child type
  - `#size` delegated to the object's children
  - `#empty?` delegated to the object's children
  - `#mode` for the object's coordinate dimension mode
  - `#srid` for the object's SRID (spatial reference identifier)
  - `#has_z?` to check the object's mode for coordinate Z
  - `#haz_m?` to check the object's mode for coordinate M
  - `#haz_zm?` to check the object's mode for both Z an M
  - `#kind` a convenience enum for the object's type

All `WKB::Geometry` descendants and `WKB::Position` have the method:
  
  - `#to_coordinates` to create a (nested) `Float64` array with the respective coordinates

### Position

The base element to represent coordinates in geometry objects.

```crystal
position2D  = WKB::Position.new([1.0, 2.0]) # defaults to WKB::Mode::XY
position3Dz = WKB::Position.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
position3Dm = WKB::Position.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
position4D  = WKB::Position.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
position2D.x # => 1.0
position2D.has_z? # => false
position.z.nan? # => true
position4D.has_zm? # => true
position4D.m # => 4.0
position_empty = WKB::Point.new([] of Float64)
position4D_empty = WKB::Point.new([] of Float64, mode: WKB::Mode::XYZM)
```

### Point

The simplest of geometry objects. A `WKB::Point` has a single position to which it delegates most of its methods. The creation and properties of a point are similar to that of a position, but it also has a SRID.

```crystal
point2D  = WKB::Point.new([1.0, 2.0])
point3D = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
point2D.position # => WKB::Position(@slice=Slice[1.0, 2.0], @mode=WKB::Mode::XY)
point2D.srid # => 0
point_with_srid = WKB::Point.new([1.0, 2.0], srid: 4326)
point_with_srid.srid # => 4326 
```

For consistency with other geometry objects, the method `#children` returns an array with the point's single position, with the latter being possibly empty. Hence, if not empty, the point's `#size` will always be 1.

### LineString

A `WKB::LineString` has an array of positions as children. However trying to create a `WKB::LineString` with a single position will raise `WKB::Error`. For convenience, the struct includes `Indexable(WKB::Position)`.

```crystal
line_string = WKB::LineString.new([[1.0, 2.0],[3.0, 4.0]])
line_string.positions.first # => WKB::Position(@slice=Slice[1.0, 2.0], @mode=WKB::Mode::XY)
line_string.children.first # same
line_string.first # same
```

### Polygon

A `WKB::Polygon` has line strings as children, all of which must be _rings_ if not empty (i.e., have a least four positions, with the first and last ones being the same), otherwise a `WKB::Error` will be raised. If not empty, the first line string is the _exterior ring_, and the rest are the _interior rings_.

```crystal
polygon = WKB::Polygon.new([
  [
    [20.0, 30.0],
    [35.0, 35.0],
    [30.0, 20.0],
    [20.0, 30.0]
  ]
])
polygon.line_strings.first # => <WKB::LineString>
polygon.children.first # same
polygon.exterior_ring #idem
polygon.interior_rings # => [] of WKB::LineString
```

### MultiPoint

A `WKB::MultiPoint` is a multipart object that has points as children.

```crystal
multi_point = WKB::MultiPoint.new([
  [1.0, 2.0],
  [3.0, 4.0]
])
multi_point.points.first # => <WKB::Point>
multi_point.children.first # same
```

### MultiLineString

A `WKB::MultiLineString` is a multipart object that has line strings as children.

```crystal
multi_line_string = WKB::MultiLineString.new([
  [
    [20.0, 30.0],
    [35.0, 35.0],
    [30.0, 20.0]
  ]
])
multi_line_string.line_strings.first # => <WKB::LineString>
multi_line_string.children.first # same
```

### MultiPolygon

A `WKB::Polygon` is a multipart object that has polygons as children.

```crystal
multi_polygon = WKB::MultiPolygon.new([
  [
    [
      [40.0, 40.0],
      [20.0, 45.0],
      [45.0, 30.0],
      [40.0, 40.0]
    ]
  ]
])
multi_polygon.polygons.first # => <WKB::Polygon>
multi_polygon.children.first # same
```

### GeometryCollection

A `WKB::GeometryCollection` is a composite object that has other geometry objects as children. In this library, the children of a geometry collection, if not empty, MUST be heterogenous instances of `WKB::Geometry`. If you need to hold a collection of simple homogeneous geometries, use the respective multipart geometry object.

```crystal
point = WKB::Point.new([1.0, 2.0])
line_string = WKB::LineString.new([[1.0, 2.0],[3.0, 4.0]])
geometry_collection = WKB::GeometryCollection.new([point, line_string])
geometry_collection.geometries # => <Array(WKB::Geometry)>
geometry_collection.children # same
```

## Serialization

The main scope of this library is to support encoding and decoding in the aforementioned four flavors of WKB. Support for WKT and GeoJSON is limited to simple but inflexible use cases which may or may not fulfill your specific needs.

### Well-Known Binary

To encode WKB, create an instance of `WKB::BinEncoder`, which has a flavor (defaults to Standard WKB) and a byte format (defaults to little endian). Remember that Standard WKB can be used only with XY. You can encode into `Bytes` or you can also encode directly into an `IO` instance. Empty points are encoded with coordinates set to `Float64::NAN`, in line with PostGIS and the GEOS C/C++ library.

```crystal
encoder = WKB::BinEncoder.new
encoder.flavor # => WKB::Flavor::Basic
encoder.format # => IO::ByteFormat::LittleEndian
point2D = WKB::Point.new([1.0, 2.0])
bytes = encoder.encode(point2D)
bytes.hexstring # => "0101000000000000000000f03f0000000000000040"
point_empty = WKB::Point.new([])
bytes = encoder.encode(point_empty)
bytes.hexstring # => "0101000000000000000000f87f000000000000f87f"
io = IO::Memory.new
encoder.encode(point2D, io)

point3D = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
ext_encoder = WKB::BinEncoder.new(WKB::Flavor::Ext)
iso_encoder = WKB::BinEncoder.new(WKB::Flavor::ISO)
bytes = ext_encoder.encode(point3D)
bytes.hexstring # => "0101000080000000000000f03f00000000000000400000000000000840"
bytes = iso_encoder.encode(point3D)
bytes.hexstring # => "01e9030000000000000000f03f00000000000000400000000000000840"
```

If you want to support encoding the SRID in EWKB only when needed, i.e., with a non-zero value, you'll need two encoders.

```crystal
ext_encoder = WKB::BinEncoder.new(WKB::Flavor::Ext)
ext_srid_encoder = WKB::BinEncoder.new(WKB::Flavor::ExtSRID)

def encode_ewkb_with_optional_srid(object : WKB::Object) : Bytes
  if object.srid.zero?
    ext_encoder.encode(object)
  else
    ext_srid_encoder.encode(object)
  end
end
```

To decode a `WKB::Object`, create an instance of `WKB::BinDecoder`; it automatically decodes all supported flavors and both byte formats, and you can set a default SRID. You can decode from `Bytes`, from an `IO` instance, or from a `String` hexadecimal representation of the binary geometry object.

If you need to work with a specific type of `WKB::Object` you can: (1) use the `#is_a?` pseudo-method for safe use within an _if block_; (2) cast the object, optionally using the object's `#kind` method to check before casting.

```crystal
decoder = WKB::BinDecoder.new
point_wkb_str = "0101000000000000000000f03f0000000000000040"
object = decoder.decode(point_wkb_str) # => <WKB::Object+>
object.empty? # => false

# Desired type known at compile time, if true it's safe to use point methods
if object.is_a?(WKB::Point) 
  object.x # => 1.0
end

# For more dynamic scenarios we can verify kind and then safely cast
object.kind.point? # => true
point = object.as(WKB::Point) 
point.x # => 1.0

# Sometimes it's better to use the more generic struct
object.kind.geometry? # => true
geometry = object.as(WKB::Geometry)
geometry.to_coordinates # => [1.0, 2.0] 

encoder = WKB::BinEncoder.new
io = IO::Memory.new
encoder.encode(point, io)
io.rewind
another_point = decoder.decode(io).as(WKB::Point)
another_point == point # => true

point.srid # => 0
decoder = WKB::BinDecoder.new(default_srid = 4326)
decoder.decode(point_wkb_str).srid # => 4326
```

### Well-Known Text

WKT is a commonly-used and human-readable representation of geometry objects. This library's support for encoding and decoding WKT is limited, however. In particular, there is no float precision control on encoding, and decoding 3D and 4D geometries in EWKT (used by PostGIS) is not supported, but the respective encoding in EWKT is supported. ISO WKT is better supported.

To encode WKT, create an instance of `WKB::TextEncoder`, which has a flavor (defaults to Standard WKT). You can encode to a `String` or into an `IO` instance. For optional SRID encoding in EWKT adapt the example for WKB.

```crystal
encoder = WKB::TextEncoder.new
encoder.flavor # => WKB::Flavor::Basic
point2D = WKB::Point.new([1.0, 2.0])
encoder.encode(point2D) # => "POINT(1.0 2.0)"
io = IO::Memory.new
encoder.encode(point2D)

point3D = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
ext_encoder = WKB::TextEncoder.new(WKB::Flavor::Ext)
ext_srid_encoder = WKB::TextEncoder.new(WKB::Flavor::ExtSRID)
iso_encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
ext_encoder.encode(point3D) # => "POINT(1.0 2.0 3.0)
ext_srid_encoder.encode(point3D) # => "SRID=0;POINT(1.0 2.0 3.0)"
iso_encoder.encode(point3D) # => "POINT Z(1.0 2.0 3.0)"
```

To decode WKT, create an instance of `WKB::TextDecoder`, for which you can set a default SRID. You can decode only from a `String` instance. The same casting restrictions as decoding WKB apply.

```crystal
decoder = WKB::TextDecoder.new
point_wkt_str = "POINT Z(1.0 2.0 3.0)"
object = decoder.decode(point_wkt_str) # => <WKB::Object+>
object.empty? # => false
object.mode.xyz? # => true
if object.is_a?(WKB::Geometry)
  object.to_coordinates # => [1.0, 2.0, 3.0]
end
object.kind.point? # => true
point = object.as(WKB::Point)
point.z # => 3.0
decoder = WKB::TextDecoder.new(default_srid = 4326)
decoder.decode(point_wkt_str).srid # => 4326
```

### GeoJSON

This library provides an optional extension to consume and (efficiently) produce a subset of GeoJSON. Only the above seven geometry objects are supported. GeoJSON's Feature and Feature Collection are not supported. In addition, no foreign properties are supported and parsing is case and order sensitive. 

By default, all 3D coordinates are XYZ; four or more coordinates are not supported by GeoJSON. Empty objects are supported, with their mode set to XY. Mixing empty objects with other 3D object within composite objects will raise a `WKB::Error`.

You'll need to load the extension after the library. This will load Crystal's JSON module and add `.from_json` and `#to_json` to positions and geometry objects, together with their JSON-related methods.

```crystal
require "wkb"
require "wkb/geojson"

point2D = WKB::Point.new([1.0, 2.0])

point2D_json = point2D.to_json
point2D_json # => "{\"type\":\"Point\",\"coordinates\":[1.0,2.0]}"
another_point2D = WKB::Point.from_json(point2D_json)
another_point2D == point2D # => true

point2D.position.to_json # => "[1.0,2.0]"

point3D_json = "{\"type\":\"Point\",\"coordinates\":[1.0,2.0,3.0]}"
object = WKB::Object.from_json(point3D_json)
object.kind.point? # => true
point3D = object.as(WKB::Point)
point3D.mode.xyz? # => true

WKB::Point.new([] of Float64).to_json # => "{\"type\":\"Point\",\"coordinates\":[]}"
```

If you need more GeoJSON features I suggest using the following library by [@mamantoha](https://github.com/mamantoha):

  * https://github.com/geocrystal/geojson

Using both libraries, going from WKB to GeoJSON is straightforward; viceversa less so.

```crystal
require "wkb"
require "geojson"

wkb_line_string = WKB::LineString.new([[1.0, 2.0], [4.0, 5.0]])
gjo_line_string = GeoJSON::LineString.new(wkb_line_string.to_coordinates)

wkb_polygon = WKB::Polygon.new([
  [
    [20.0, 30.0],
    [35.0, 35.0],
    [30.0, 20.0],
    [20.0, 30.0]
  ]
])
gjo_polygon = GeoJSON::Polygon.new(wkb_polygon.to_coordinates)


point_json = "{\"type\":\"Point\",\"coordinates\":[1.0,2.0]}"
multi_point_json = "{\"type\":\"MultiPoint\",\"coordinates\":[[1.0,2.0],[3.0,4.0]]}"

# "geojson" uses the class `GeoJSON::Coordinates` as the basis for the `coordinates`
#   property of all of its geometry objects, class which itself wraps an `Array(Float64)`
#   in a property called `coordinates`.

#  Here we need to call two times `#coordinates`.
gjo_point = GeoJSON::Point.from_json(point_json)
wkb_point = WKB::Point.new(gjo_point.coordinates.coordinates)

#  Here we need to map the array of `GeoJSON::Coordinates`.
gjo_multi_point = GeoJSON::MultiPoint.from_json(multi_point_json)
wkb_multi_point = WKB::Point.new(gjo_multi_point.coordinates.map(&.coordinates))
```

Given that the extension is optional, you could also implement your own (Geo)JSON serialization.

## Geometries on a Database

This library can be used to communicate with any system that implements WKB, including many database engines. In that case, you can either work at the bytes level doing the conversion yourself, or use  converters for `WKB::Object` and all its descendants for easier reading with `DB::Serializable` from `crystal-db`.

Below is a full example to receive and transmit geometry data from and to PostGIS using [crystal-pg](https://github.com/will/crystal-pg), the Postgres driver for [crystal-db](https://github.com/crystal-lang/crystal-db).

```crystal
require "db"
require "pg"
require "wkb"
require "wkb/geojson" # For GeoJSON support
require "wkb/db" # For `DB::Serializable` support. Must be loaded after "db"!

decoder = WKB::BinDecoder.new
encoder = WKB::BinEncoder.new(WKB::Flavor::Ext) # or `ExtSRID` if you use SRID

polygon_json = <<-JSON
  {
    "type": "Polygon", 
    "coordinates": [
      [
          [35.0, 10.0],
          [45.0, 45.0],
          [15.0, 40.0],
          [10.0, 20.0],
          [35.0, 10.0]
      ]
    ]
  }
JSON

class Place
  include DB::Serializable

  property name : String

  @[DB::Field(converter: WKB::DB::PointConverter)]
  property location : WKB::Point
end

DB.open("postgres://user:password@host:port/db_name") do |db|
  point_bytes = db.scalar("SELECT 'POINT(1 2 3)'::GEOMETRY;").as(Bytes)
  point = decoder.decode(point_bytes).as(WKB::Point)
  point.z # => 3.0
  point.to_json # => "{\"type\":\"Point\",\"coordinates\":[1.0,2.0,3.0]}

  line_string = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0]])
  line_string_bytes = encoder.encode(line_string)
  num_points = db.scalar("SELECT ST_NumPoints($1::GEOMETRY)", line_string_bytes).as(Int32)
  num_points # => 2

  polygon = WKB::Polygon.from_json(polygon_json)
  polygon_bytes = encoder.encode(polygon)
  polygon_perimeter = db.scalar("SELECT ST_Perimeter($1::GEOMETRY)", polygon_bytes).as(Float64)
  polygon_perimeter # => 114.35571426165451

  query_str = "SELECT 'Neverland' AS name, 'POINT(1 2)'::GEOMETRY AS location"
  places = Place.from_rs(db.query(query_str))
  places.first.location.x # => 1.0
end
```

Please note the casting to `GEOMETRY` within PostGIS functions. Data is sent as `BYTEA`, and I've found that some functions accept the binary as is, while others expect a `GEOMETRY` datatype. I suggest to always cast.
Unfortunately, and as far as I'm aware, in `crystal-pg` at the moment there is no support for custom types with dynamic OIDs such as those in PostGIS, hence the above casting seems unavoidable.

### Use with ORMs

Perhaps the ORM or framework of your choice supports creating custom fields when working with a database. This is the case of [Marten](https://martenframework.com/) with its [custom model fields](https://martenframework.com/docs/models-and-databases/how-to/create-custom-model-fields) and [Lucky](https://luckyframework.org/) via the non-documented extensions for [Avram](https://github.com/luckyframework/avram).

#### Lucky's Avram

Below just an example of creating an extension for Lucky's Avram to work with PostGIS. In this case we only support the generic `WKB::Object`, but you can be more specific if desired.

```crystal
abstract struct WKB::Object
  def self.adapter
    Lucky
  end

  module Lucky
    @@bin_decoder = WKB::BinDecoder.new
    @@bin_encoder = WKB::BinEncoder.new
    @@text_decoder = WKB::TextDecoder.new
    @@text_encoder = WKB::TextEncoder.new

    alias ColumnType = Bytes # The base type of `WKB::Object` for our Postgres driver
    include Avram::Type

    def self.criteria(query : T, column) forall T
      Criteria(T, Bytes).new(query, column)
    end

    def from_db!(value : Bytes)
      @@bin_decoder.decode(value)
    end

    def parse(value : WKB::Object)
      SuccessfulCast(WKB::Object).new(value)
    end

    def parse(value : Bytes)
      object = @@bin_decoder.decode(value)
      SuccessfulCast(WKB::Object).new(object)
    rescue
      FailedCast.new
    end

    def parse(value : String)
      object = @@text_decoder.decode(value).as(WKB::Object)
      SuccessfulCast(WKB::Object).new(object)
    rescue
      FailedCast.new
    end

    def to_db(value : WKB::Object)
      @@text_encoder.encode(value)
    end

    class Criteria(T, V) < Avram::Criteria(T, V)
    end
  end
end

# The following is needed to add support for `WKB::Object` in migrations
module Avram::Migrator::Columns
  module WKB
    class ObjectColumn(T) < Base
      @default : T | Nil = nil

      def initialize(@name, @nilable, @default)
      end

      # The datatype "geometry is encoded as EWKB and it's the most used datatype in PostGIS.
      #   Another possible value is "geography", useful when working on a global scale.
      #   See: https://postgis.net/workshops/postgis-intro/geography.html
      def column_type : String
        "geometry" 
      end
    end
  end
end
```

Remember to load your extension where appropriate in your Lucky's `app.cr`. For instance, you could create a folder `src/charms` to gather all Avram extensions and require it after your shards and before your models, like so:

```crystal
require "./shards"

require "../config/server"
require "./app_database"
require "../config/**"
require "./charms/**" # Our WKB extension for Avram's lucky is within this folder
require "./models/base_model"
# Rest of "require"
```

Now you can create migrations like this one:

```crystal
class CreatePlace::V00000000000001 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Place) do
      primary_key id : Int64
      add_timestamps
      add name : String
      add location : WKB::Object # We can use `WKB::Object` for datatype "geometry"
    end
  end

  def rollback
    drop table_for(Place)
  end
end
```

For the respective model:

```crystal
class Place < BaseModel
  # columns for primary key and timestamps are already included by default
  table do
    column name : String
    column location : WKB::Object
  end
end
```

You can further customize your extension(s) to support only specific types or other encodings, such as including the SRID or making it optional.

For instance, to only support `WKB::Point` you would need to cast as necessary while parsing `Bytes` or `String` in the respective `Lucky` module:

```crystal
  def parse(value : Bytes)
    object = @@bin_decoder.decode(value)
    if object.kind.point?
      SuccessfulCast(WKB::Point).new(object.as(WKB::Point))
    else
      raise "Not a valid Point"
    end
  rescue
    FailedCast.new
  end
```

Remember to also adapt as necessary the column type for Avram migrations:

```crystal
  def column_type : String
    # Accept only Points with default PostGIS SRID set 4326, the same as GeoJSON.
    "geometry(point, 4326)" 
  end
```

## Contributing

1. Fork it (<https://github.com/your-github-user/crystal-wkb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Amaury Trujillo](https://github.com/amauryt) - creator and maintainer
