require "../spec_helper"

describe WKB::TextEncoder do
  context "when Point" do
    it "encodes an empty Point" do
      encoder = WKB::TextEncoder.new
      object = WKB::Point.new([] of Float64)
      text = "POINT EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a Point" do
      encoder = WKB::TextEncoder.new
      object = WKB::Point.new([1.0, 2.0])
      text = "POINT(1.0 2.0)"
      encoder.encode(object).should eq(text)
    end

    it "encodes a Point with negative values" do
      encoder = WKB::TextEncoder.new
      object = WKB::Point.new([-1.0, -2.0])
      text = "POINT(-1.0 -2.0)"
      encoder.encode(object).should eq(text)
    end

    context "when ISO flavor" do
      it "encodes a Point with Z" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        text = "POINT Z(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with M" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
        text = "POINT M(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with ZM" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
        text = "POINT ZM(1.0 2.0 3.0 4.0)"
        encoder.encode(object).should eq(text)
      end
    end

    context "when Ext flavor" do
      it "encodes a Point with Z" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        text = "POINT(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with M" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
        text = "POINTM(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with ZM" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
        text = "POINTM(1.0 2.0 3.0 4.0)"
        encoder.encode(object).should eq(text)
      end
    end

    context "when ExtSRID flavor" do
      it "encodes a Point with SRID" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ExtSRID)
        object = WKB::Point.new([1.0, 2.0], srid: 1000)
        text = "SRID=1000;POINT(1.0 2.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with SRID and Z" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ExtSRID)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ, srid: 1000)
        text = "SRID=1000;POINT(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with SRID and M" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ExtSRID)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM, srid: 1000)
        text = "SRID=1000;POINTM(1.0 2.0 3.0)"
        encoder.encode(object).should eq(text)
      end

      it "encodes a Point with SRID and ZM" do
        encoder = WKB::TextEncoder.new(WKB::Flavor::ExtSRID)
        object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM, srid: 1000)
        text = "SRID=1000;POINTM(1.0 2.0 3.0 4.0)"
        encoder.encode(object).should eq(text)
      end
    end
  end

  context "when LineString" do
    it "encodes an empty LineString" do
      encoder = WKB::TextEncoder.new
      object = WKB::LineString.new([] of Array(Float64))
      text = "LINESTRING EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a basic LineString" do
      encoder = WKB::TextEncoder.new
      object = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
      text = "LINESTRING(1.0 2.0, 3.0 4.0, 5.0 6.0)"
      encoder.encode(object).should eq(text)
    end

    it "encodes a LineString with Z" do
      encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
      object = WKB::LineString.new(
        [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]],
        WKB::Mode::XYZ
      )
      text = "LINESTRING Z(1.0 2.0 3.0, 4.0 5.0 6.0, 7.0 8.0 9.0)"
      encoder.encode(object).should eq(text)
    end

    it "encodes a LineString with M" do
      encoder = WKB::TextEncoder.new(WKB::Flavor::ISO)
      object = WKB::LineString.new(
        [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]],
        WKB::Mode::XYM
      )
      text = "LINESTRING M(1.0 2.0 3.0, 4.0 5.0 6.0, 7.0 8.0 9.0)"
      encoder.encode(object).should eq(text)
    end
  end

  context "when is Polygon" do
    it "encodes an empty Polygon" do
      encoder = WKB::TextEncoder.new
      object = WKB::Polygon.new([] of Array(Array(Float64)))
      text = "POLYGON EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a basic Polygon" do
      encoder = WKB::TextEncoder.new
      object = WKB::Polygon.new([
        [[1.0, 2.0], [3.0, 4.0], [5.0, 7.0], [1.0, 2.0]],
      ])
      text = "POLYGON((1.0 2.0, 3.0 4.0, 5.0 7.0, 1.0 2.0))"
      encoder.encode(object).should eq(text)
    end

    it "encodes a basic Polygon with holes" do
      encoder = WKB::TextEncoder.new
      object = WKB::Polygon.new([
        [[35.0, 10.0], [45.0, 45.0], [15.0, 40.0], [10.0, 20.0], [35.0, 10.0]],
        [[20.0, 30.0], [35.0, 35.0], [30.0, 20.0], [20.0, 30.0]],
      ])
      text = "POLYGON((35.0 10.0, 45.0 45.0, 15.0 40.0, 10.0 20.0, 35.0 10.0), " \
             "(20.0 30.0, 35.0 35.0, 30.0 20.0, 20.0 30.0))"
      encoder.encode(object).should eq(text)
    end
  end

  context "when is MultiPoint" do
    it "encodes an empty MultiPoint" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiPoint.new([] of Array(Float64))
      text = "MULTIPOINT EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a basic MultiPoint" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiPoint.new([[1.0, 2.0], [0.0, 3.0]])
      text = "MULTIPOINT((1.0 2.0), (0.0 3.0))"
      encoder.encode(object).should eq(text)
    end
  end

  context "when is MultiLineString" do
    it "encodes an empty MultiLineString" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiLineString.new([] of Array(Array(Float64)))
      text = "MULTILINESTRING EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a basic MultiLineString" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiLineString.new([
        [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]],
        [[0.0, -3.0], [0.0, -4.0], [1.0, -5.0]],
      ])
      text = "MULTILINESTRING((1.0 2.0, 3.0 4.0, 5.0 6.0), (0.0 -3.0, 0.0 -4.0, 1.0 -5.0))"
      encoder.encode(object).should eq(text)
    end
  end

  context "when is MultiPolygon" do
    it "encodes an empty MultiPolygon" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiPolygon.new([] of Array(Array(Array(Float64))))
      text = "MULTIPOLYGON EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a MultiPolygon" do
      encoder = WKB::TextEncoder.new
      object = WKB::MultiPolygon.new([
        [[[40.0, 40.0], [20.0, 45.0], [45.0, 30.0], [40.0, 40.0]]],
        [
          [[20.0, 35.0], [10.0, 30.0], [10.0, 10.0], [30.0, 5.0], [45.0, 20.0], [20.0, 35.0]],
          [[30.0, 20.0], [20.0, 15.0], [20.0, 25.0], [30.0, 20.0]],
        ],
      ])
      text = "MULTIPOLYGON(((40.0 40.0, 20.0 45.0, 45.0 30.0, 40.0 40.0)), " \
             "((20.0 35.0, 10.0 30.0, 10.0 10.0, 30.0 5.0, 45.0 20.0, 20.0 35.0), " \
             "(30.0 20.0, 20.0 15.0, 20.0 25.0, 30.0 20.0)))"
      encoder.encode(object).should eq(text)
    end
  end

  context "when is GeometryCollection" do
    it "encodes an empty GeometryCollection" do
      encoder = WKB::TextEncoder.new
      object = WKB::GeometryCollection.new([] of WKB::Geometry)
      text = "GEOMETRYCOLLECTION EMPTY"
      encoder.encode(object).should eq(text)
    end

    it "encodes a GeometryCollection" do
      encoder = WKB::TextEncoder.new
      object = WKB::GeometryCollection.new([
        WKB::Point.new([-1.0, -2.0]),
        WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]),
      ])
      text = "GEOMETRYCOLLECTION(POINT(-1.0 -2.0), LINESTRING(1.0 2.0, 3.0 4.0, 5.0 6.0))"
      encoder.encode(object).should eq(text)
    end
  end
end
