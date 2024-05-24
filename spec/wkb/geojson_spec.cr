require "../spec_helper"
require "../../src/wkb/geojson"

describe "GeoJSON extension" do
  # Examples taken from https://en.wikipedia.org/wiki/GeoJSON

  point_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "Point", 
        "coordinates": [30.0, 10.0]
      }
    JSON

  line_string_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "LineString", 
        "coordinates": [
            [30.0, 10.0],
            [10.0, 30.0],
            [40.0, 40.0]
        ]
      }
    JSON

  polygon_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "Polygon", 
        "coordinates": [
            [
                [35.0, 10.0],
                [45.0, 45.0],
                [15.0, 40.0],
                [10.0, 20.0],
                [35.0, 10.0]
            ],
            [
                [20.0, 30.0],
                [35.0, 35.0],
                [30.0, 20.0],
                [20.0, 30.0]
            ]
          ]
      }
    JSON

  multi_point_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "MultiPoint", 
        "coordinates": [
            [10.0, 40.0],
            [40.0, 30.0],
            [20.0, 20.0],
            [30.0, 10.0]
        ]
      }
    JSON

  multi_line_string_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "MultiLineString", 
        "coordinates": [
            [
                [10.0, 10.0],
                [20.0, 20.0],
                [10.0, 40.0]
            ],
            [
                [40.0, 40.0],
                [30.0, 30.0],
                [40.0, 20.0],
                [30.0, 10.0]
            ]
        ]
      }
    JSON

  multi_polygon_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "MultiPolygon", 
        "coordinates": [
            [
                [
                    [40.0, 40.0],
                    [20.0, 45.0],
                    [45.0, 30.0],
                    [40.0, 40.0]
                ]
            ], 
            [
                [
                    [20.0, 35.0],
                    [10.0, 30.0],
                    [10.0, 10.0],
                    [30.0, 5.0],
                    [45.0, 20.0],
                    [20.0, 35.0]
                ],
                [
                    [30.0, 20.0],
                    [20.0, 15.0],
                    [20.0, 25.0],
                    [30.0, 20.0]
                ]
            ]
        ]
      }
    JSON

  geometry_collection_json = <<-JSON.gsub(/\s/, "")
      {
        "type": "GeometryCollection",
        "geometries": [
            {
                "type": "Point",
                "coordinates": [40.0, 10.0]
            },
            {
                "type": "LineString",
                "coordinates": [
                    [10.0, 10.0],
                    [20.0, 20.0],
                    [10.0, 40.0]
                ]
            },
            {
                "type": "Polygon",
                "coordinates": [
                    [
                        [40.0, 40.0],
                        [20.0, 45.0],
                        [45.0, 30.0],
                        [40.0, 40.0]
                    ]
                ]
            }
        ]
      }
    JSON

  it "deserializes and serializes a Point" do
    point = WKB::Point.from_json(point_json)
    point.x.should eq(30.0)
    point.y.should eq(10.0)
    point.to_json.should eq(point_json)
  end

  it "deserializes and serializes a Point with Z" do
    point_3d_json = %[{"type":"Point","coordinates":[1.0,2.0,3.0]}]
    point = WKB::Point.from_json(point_3d_json)
    point.x.should eq(1.0)
    point.y.should eq(2.0)
    point.z.should eq(3.0)
    point.to_json.should eq(point_3d_json)
  end

  it "deserializes and serializes an empty Point" do
    point_empty_json = %[{"type":"Point","coordinates":[]}]
    point = WKB::Point.from_json(point_empty_json)
    point.to_json.should eq(point_empty_json)
  end

  it "deserializes and serializes a LineString" do
    line_string = WKB::LineString.from_json(line_string_json)
    line_string.first.x.should eq(30.0)
    line_string.first.y.should eq(10.0)
    line_string.last.x.should eq(40.0)
    line_string.last.y.should eq(40.0)
    line_string.to_json.should eq(line_string_json)
  end

  it "deserializes and serializes a Polygon" do
    polygon = WKB::Polygon.from_json(polygon_json)
    polygon.size.should eq(2)
    polygon.line_strings.first.first.x.should eq(35.0)
    polygon.line_strings.first.first.y.should eq(10.0)
    polygon.line_strings.last.last.x.should eq(20.0)
    polygon.line_strings.last.last.y.should eq(30.0)
    polygon.to_json.should eq(polygon_json)
  end

  it "deserializes and serializes a MultiPoint" do
    multi_point = WKB::MultiPoint.from_json(multi_point_json)
    multi_point.points.first.x.should eq(10.0)
    multi_point.points.first.y.should eq(40.0)
    multi_point.points.last.x.should eq(30.0)
    multi_point.points.last.y.should eq(10.0)
    multi_point.to_json.should eq(multi_point_json)
  end

  it "deserializes and serializes a MultiLineString" do
    multi_line_string = WKB::MultiLineString.from_json(multi_line_string_json)
    multi_line_string.line_strings.first.first.x.should eq(10.0)
    multi_line_string.line_strings.first.first.y.should eq(10.0)
    multi_line_string.line_strings.last.last.x.should eq(30.0)
    multi_line_string.line_strings.last.last.y.should eq(10.0)
    multi_line_string.to_json.should eq(multi_line_string_json)
  end

  it "deserializes and serializes a MultiPolygon" do
    multi_polygon = WKB::MultiPolygon.from_json(multi_polygon_json)
    multi_polygon.polygons.first.line_strings.first.first.x.should eq(40.0)
    multi_polygon.polygons.first.line_strings.first.first.y.should eq(40.0)
    multi_polygon.polygons.last.line_strings.last.last.x.should eq(30.0)
    multi_polygon.polygons.last.line_strings.last.last.y.should eq(20.0)
    multi_polygon.to_json.should eq(multi_polygon_json)
  end

  it "deserializes and serializes a GeometryCollection" do
    geometry_collection = WKB::GeometryCollection.from_json(geometry_collection_json)
    geometry_collection.geometries[0].should be_a(WKB::Point)
    geometry_collection.geometries[1].should be_a(WKB::LineString)
    geometry_collection.geometries[2].should be_a(WKB::Polygon)
    geometry_collection.geometries.first.should eq(WKB::Point.new([40.0, 10.0]))
    geometry_collection.to_json.should eq(geometry_collection_json)
  end

  it "deserializes and serializes an empty GeometryCollection" do
    json = %[{"type":"GeometryCollection","geometries":[]}]
    geometry_collection = WKB::GeometryCollection.from_json(json)
    geometry_collection.empty?.should be_true
    geometry_collection.to_json.should eq(json)
  end

  context "when parsing erroneous GeoJSON" do
    it "raises on unrelated JSON" do
      json = %{[1.0, 2.0]}
      expect_raises(JSON::ParseException) do
        WKB::Object.from_json(json)
      end
    end

    it "raises on an unsupported type" do
      json = %[{"type":"Unknown","coordinates":[0.0,0.0]}]
      expect_raises(JSON::ParseException, /Unknown/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if 'coordinates' is not the second key for a Geometry" do
      json = %[{"type":"Point","other":1,"coordinates":[0.0,0.0]}]
      expect_raises(JSON::ParseException, /coordinates/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if 'coordinates' has only one element" do
      json = %[{"type":"Point","coordinates":[0.0]}]
      expect_raises(JSON::ParseException, /element/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if 'coordinates' has more than three elements" do
      json = %[{"type":"Point","coordinates":[1.0,2.0,3.0,4.0]}]
      expect_raises(JSON::ParseException, /element/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if 'geometries' is not the second key for a GeometryCollection" do
      json = %[{"type":"GeometryCollection","other":1,"geometries":[]}]
      expect_raises(JSON::ParseException, /geometries/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if child geometries have diferent dimension modes" do
      json = %[{"type":"MultiPoint","coordinates":[[1.0,2.0,3.0],[4.0,5.0]]}]
      expect_raises(WKB::Error, /coordinates/) do
        WKB::Object.from_json(json)
      end
    end

    it "raises if the specific geometry type is not correct" do
      json = %[{"type":"Point","coordinates":[1.0,2.0]}]
      expect_raises(TypeCastError) do
        WKB::MultiPoint.from_json(json)
      end
    end
  end
end
