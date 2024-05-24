require "../spec_helper"

# Most test data taken from:
# https://github.com/rgeo/rgeo/blob/main/test/wkrep/wkt_generator_test.rb

describe WKB::TextDecoder do
  context "when Point" do
    it "decodes an empty Point" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([] of Float64)
      text = "POINT EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic Point" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0])
      text = "POINT(1.0 2.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with default SRID" do
      decoder = WKB::TextDecoder.new(default_srid: 1000)
      object = WKB::Point.new([1.0, 2.0], srid: 1000)
      text = "POINT(1.0 2.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with negative values" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([-1.0, -2.0])
      text = "POINT(-1.0 -2.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with integer strings" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, -2.0])
      text = "POINT(1 -2)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with mixed case" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0])
      text = "Point(1.0 2.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with space before opening paren" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0])
      text = "POINT (1.0 2.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with Z" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
      text = "POINT Z(1.0 2.0 3.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with M" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
      text = "POINT M(1.0 2.0 3.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with ZM" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
      text = "POINT ZM(1.0 2.0 3.0 4.0)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a Point with SRID" do
      decoder = WKB::TextDecoder.new
      object = WKB::Point.new([1.0, 2.0], srid: 1000)
      text = "SRID=1000;POINT(1.0 2.0)"
      decoder.decode(text).should eq(object)
    end

    it "raises with too few coordinates" do
      decoder = WKB::TextDecoder.new
      text = "POINT(1.0)"
      expect_raises(WKB::DecodeError) do
        decoder.decode(text)
      end
    end

    it "raises with too many coordinates" do
      decoder = WKB::TextDecoder.new
      text = "POINT M(1.0 2.0 3.0 4.0)"
      expect_raises(WKB::DecodeError) do
        decoder.decode(text)
      end
    end

    it "decodes two consecutive points with different modes" do
      decoder = WKB::TextDecoder.new
      object1 = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
      text1 = "POINT Z(1.0 2.0 3.0)"
      object2 = WKB::Point.new([1.0, 2.0])
      text2 = "POINT(1.0 2.0)"
      decoder.decode(text1).should eq(object1)
      decoder.decode(text2).should eq(object2)
    end
  end

  context "when LineString" do
    it "decodes an empty LineString" do
      decoder = WKB::TextDecoder.new
      object = WKB::LineString.new([] of Array(Float64))
      text = "LINESTRING EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic LineString" do
      decoder = WKB::TextDecoder.new
      object = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
      text = "LINESTRING(1 2, 3 4, 5 6)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a LineString with Z" do
      decoder = WKB::TextDecoder.new
      object = WKB::LineString.new(
        [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]],
        WKB::Mode::XYZ
      )
      text = "LINESTRING Z(1 2 3, 4 5 6, 7 8 9)"
      decoder.decode(text).should eq(object)
    end

    it "decodes a LineString with M" do
      decoder = WKB::TextDecoder.new
      object = WKB::LineString.new(
        [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]],
        WKB::Mode::XYM
      )
      text = "LINESTRING M(1 2 3, 4 5 6, 7 8 9)"
      decoder.decode(text).should eq(object)
    end

    it "raises with inconsistent coordinates" do
      decoder = WKB::TextDecoder.new
      text = "LINESTRING(1 2 3, 4 5,7 8 9)"
      expect_raises(WKB::DecodeError) do
        decoder.decode(text)
      end
    end
  end

  context "when is Polygon" do
    it "decodes an empty Polygon" do
      decoder = WKB::TextDecoder.new
      object = WKB::Polygon.new([] of Array(Array(Float64)))
      text = "POLYGON EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic Polygon" do
      decoder = WKB::TextDecoder.new
      object = WKB::Polygon.new([
        [[1.0, 2.0], [3.0, 4.0], [5.0, 7.0], [1.0, 2.0]],
      ])
      text = "POLYGON((1 2, 3 4, 5 7, 1 2))"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic Polygon with holes" do
      decoder = WKB::TextDecoder.new
      object = WKB::Polygon.new([
        [[35.0, 10.0], [45.0, 45.0], [15.0, 40.0], [10.0, 20.0], [35.0, 10.0]],
        [[20.0, 30.0], [35.0, 35.0], [30.0, 20.0], [20.0, 30.0]],
      ])
      text = "POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))"
      decoder.decode(text).should eq(object)
    end
  end

  context "when is MultiPoint" do
    it "decodes an empty MultiPoint" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiPoint.new([] of Array(Float64))
      text = "MULTIPOINT EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic MultiPoint" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiPoint.new([[1.0, 2.0], [0.0, 3.0]])
      text = "MULTIPOINT((1 2),(0 3))"
      decoder.decode(text).should eq(object)
    end
  end

  context "when is MultiLineString" do
    it "decodes an empty MultiLineString" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiLineString.new([] of Array(Array(Float64)))
      text = "MULTILINESTRING EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a basic MultiLineString" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiLineString.new([
        [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]],
        [[0.0, -3.0], [0.0, -4.0], [1.0, -5.0]],
      ])
      text = "MULTILINESTRING((1 2, 3 4, 5 6),(0 -3, 0 -4, 1 -5))"
      decoder.decode(text).should eq(object)
    end
  end

  context "when is MultiPolygon" do
    it "decodes an empty MultiPolygon" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiPolygon.new([] of Array(Array(Array(Float64))))
      text = "MULTIPOLYGON EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a MultiPolygon" do
      decoder = WKB::TextDecoder.new
      object = WKB::MultiPolygon.new([
        [[[40.0, 40.0], [20.0, 45.0], [45.0, 30.0], [40.0, 40.0]]],
        [
          [[20.0, 35.0], [10.0, 30.0], [10.0, 10.0], [30.0, 5.0], [45.0, 20.0], [20.0, 35.0]],
          [[30.0, 20.0], [20.0, 15.0], [20.0, 25.0], [30.0, 20.0]],
        ],
      ])
      text = "MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40))," \
             "((20 35, 10 30, 10 10, 30 5, 45 20, 20 35)," \
             "(30 20, 20 15, 20 25, 30 20)))"
      decoder.decode(text).should eq(object)
    end
  end

  context "when is GeometryCollection" do
    it "decodes an empty GeometryCollection" do
      decoder = WKB::TextDecoder.new
      object = WKB::GeometryCollection.new([] of WKB::Geometry)
      text = "GEOMETRYCOLLECTION EMPTY"
      decoder.decode(text).should eq(object)
    end

    it "decodes a GeometryCollection" do
      decoder = WKB::TextDecoder.new
      object = WKB::GeometryCollection.new([
        WKB::Point.new([-1.0, -2.0]),
        WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]),
      ])
      text = "GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING(1 2, 3 4, 5 6))"
      decoder.decode(text).should eq(object)
    end

    it "raises with a dimension mismatch" do
      decoder = WKB::TextDecoder.new
      text = "GEOMETRYCOLLECTION(POINT(-1 -2),LINESTRING Z(1 2 0, 3 4 0, 5 6 0))"
      expect_raises(WKB::Error, /children/) do
        decoder.decode(text)
      end
    end
  end
end
