require "../spec_helper"

# Most test data taken from:
# https://github.com/rgeo/rgeo/blob/main/test/wkrep/wkb_parser_test.rb

describe WKB::BinDecoder do
  describe "byte format" do
    it "decodes with format Network (Big) Endian" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("00000000013ff00000000000004000000000000000")
      object.should be_a(WKB::Point)
      object.kind.point?.should be_true
      point = object.as(WKB::Point)
      point.x.should eq(1)
      point.y.should eq(2)
      point.z.nan?.should be_true
      point.m.nan?.should be_true
    end

    it "decodes with format System (Little) Endian" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("0101000000000000000000f03f0000000000000040")
      object.should be_a(WKB::Point)
      object.kind.point?.should be_true
      point = object.as(WKB::Point)
      point.x.should eq(1)
      point.y.should eq(2)
      point.z.nan?.should be_true
      point.m.nan?.should be_true
    end
  end

  context "when Point" do
    it "decodes an empty Point" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("0101000000000000000000f87f000000000000f87f")
      object.should be_a(WKB::Point)
      object.kind.point?.should be_true
      object.empty?.should be_true
    end

    it "decodes a Point with default SRID" do
      decoder = WKB::BinDecoder.new(default_srid: 1000)
      object = decoder.decode("00000000013ff00000000000004000000000000000")
      object.should eq(WKB::Point.new([1.0, 2.0], srid: 1000))
    end

    describe "Ext flavor" do
      it "decodes EWKB with Z" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00800000013ff000000000000040000000000000004008000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.should eq(3)
        point.m.nan?.should be_true
      end

      it "decodes EWKB with M" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00400000013ff000000000000040000000000000004008000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.nan?.should be_true
        point.m.should eq(3)
      end

      it "decodes EWKB with ZM" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00c00000013ff0000000000000400000000000000040080000000000004010000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.should eq(3)
        point.m.should eq(4)
      end

      it "decodes EWKB with Z and SRID" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00a0000001000003e83ff000000000000040000000000000004008000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.should eq(3)
        point.m.nan?.should be_true
        point.srid.should eq(1000)
      end

      it "decodes two consecutive points with different modes" do
        decoder = WKB::BinDecoder.new
        object1 = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        input1 = "00800000013ff000000000000040000000000000004008000000000000"
        object2 = WKB::Point.new([1.0, 2.0])
        input2 = "00000000013ff00000000000004000000000000000"
        decoder.decode(input1).should eq(object1)
        decoder.decode(input2).should eq(object2)
      end
    end

    describe "ISO flavor" do
      it "decodes ISO WKB with Z" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00000003e93ff000000000000040000000000000004008000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.should eq(3)
        point.m.nan?.should be_true
      end

      it "decodes ISO with M" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("00000007d13ff000000000000040000000000000004008000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.nan?.should be_true
        point.m.should eq(3)
      end

      it "decodes ISO with ZM" do
        decoder = WKB::BinDecoder.new
        object = decoder.decode("0000000bb93ff0000000000000400000000000000040080000000000004010000000000000")
        point = object.as(WKB::Point)
        point.x.should eq(1)
        point.y.should eq(2)
        point.z.should eq(3)
        point.m.should eq(4)
      end

      it "raises when ISO without enough data" do
        decoder = WKB::BinDecoder.new
        expect_raises(WKB::DecodeError) do
          decoder.decode("00000003e93ff00000000000004000000000000000")
        end
      end
    end
  end

  context "when LineString" do
    it "decodes an empty LineString" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000200000000")
      object.should be_a(WKB::LineString)
      object.kind.line_string?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic LineString" do
      decoder = WKB::BinDecoder.new
      input = "0000000002000000033ff00000000000004000000000000000400800000000000040100000000000004014000000000000" \
              "4018000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::LineString)
      object.kind.line_string?.should be_true
      line_string = object.as(WKB::LineString)
      line_string.size.should eq(3)
      line_string.mode.xy?.should be_true
      line_string.positions.first.first.should eq(1.0)
      line_string.positions.last.last.should eq(6.0)
    end

    it "decodes an EWKB LineString with Z" do
      decoder = WKB::BinDecoder.new
      input = "0080000002000000023ff00000000000004000000000000000400800000000000040100000000000004014000000000000" \
              "4018000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::LineString)
      object.kind.line_string?.should be_true
      line_string = object.as(WKB::LineString)
      line_string.size.should eq(2)
      line_string.mode.xyz?.should be_true
      line_string.positions.first.first.should eq(1.0)
      line_string.positions.last.last.should eq(6.0)
    end

    it "decodes an EWKB LineString with Z and SRID" do
      decoder = WKB::BinDecoder.new
      input = "00a0000002000003e8000000023ff0000000000000400000000000000040080000000000004010000000000000401400000000" \
              "00004018000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::LineString)
      object.kind.line_string?.should be_true
      line_string = object.as(WKB::LineString)
      line_string.size.should eq(2)
      line_string.mode.xyz?.should be_true
      line_string.positions.first.first.should eq(1.0)
      line_string.positions.last.last.should eq(6.0)
      line_string.srid.should eq(1000)
    end
  end

  context "when Polygon" do
    it "decodes an empty Polygon" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000300000000")
      object.should be_a(WKB::Polygon)
      object.kind.polygon?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic Polygon" do
      decoder = WKB::BinDecoder.new
      input = "000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000" \
              "000040140000000000003ff00000000000004000000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::Polygon)
      object.kind.polygon?.should be_true
      object.empty?.should be_false
      polygon = object.as(WKB::Polygon)
      polygon.exterior_ring.size.should eq(4)
      polygon.exterior_ring.size.should eq(4)
    end
  end

  context "when MultiPoint" do
    it "decodes an empty MultiPoint" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000400000000")
      object.should be_a(WKB::MultiPoint)
      object.kind.multi_point?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic MultiPoint" do
      decoder = WKB::BinDecoder.new
      input = "00000000040000000200000000013ff00000000000004000000000000000000000000140080000000000004010000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiPoint)
      object.kind.multi_point?.should be_true
      multi_point = object.as(WKB::MultiPoint)
      multi_point.points.size.should eq(2)
      multi_point.points.first.x.should eq(1.0)
      multi_point.points.last.y.should eq(4.0)
    end

    it "decodes a MultiPoint with mixed byte formats" do
      decoder = WKB::BinDecoder.new
      input = "0000000004000000020101000000000000000000f03f0000000000000040000000000140080000000000004010000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiPoint)
      object.kind.multi_point?.should be_true
      multi_point = object.as(WKB::MultiPoint)
      multi_point.points.size.should eq(2)
      multi_point.points.first.x.should eq(1.0)
      multi_point.points.last.y.should eq(4.0)
    end

    it "decodes an EWKB MultiPoint with Z" do
      decoder = WKB::BinDecoder.new
      input = "00800000040000000200800000013ff00000000000004000000000000000401400000000000000800000014008000000000000" \
              "40100000000000004018000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiPoint)
      object.kind.multi_point?.should be_true
      object.mode.xyz?.should be_true
      multi_point = object.as(WKB::MultiPoint)
      multi_point.points.size.should eq(2)
      multi_point.points.first.x.should eq(1.0)
      multi_point.points.first.z.should eq(5.0)
      multi_point.points.last.y.should eq(4.0)
      multi_point.points.last.z.should eq(6.0)
      multi_point.points.first.m.nan?.should be_true
    end

    it "raises with an EWKB MultiPoint that has mixed byte format Z" do
      decoder = WKB::BinDecoder.new
      input = "00800000040000000200800000013ff00000000000004000000000000000401400000000000000000000014008000000000000" \
              "4010000000000000"
      expect_raises(WKB::DecodeError) do
        object = decoder.decode(input)
      end
    end
  end

  context "when MultiLineString" do
    it "decodes an empty MultiLineString" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000500000000")
      object.should be_a(WKB::MultiLineString)
      object.kind.multi_line_string?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic MultiLineString" do
      decoder = WKB::BinDecoder.new
      input = "0000000005000000020000000002000000033ff000000000000040000000000000004008000000000000401000000000000040" \
              "140000000000004018000000000000000000000200000002bff0000000000000c000000000000000c008000000000000c01000" \
              "0000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiLineString)
      object.kind.multi_line_string?.should be_true
      multi_line_string = object.as(WKB::MultiLineString)
      multi_line_string.line_strings.size.should eq(2)
      multi_line_string.line_strings.first.to_coordinates.first.should eq([1.0, 2.0])
      multi_line_string.line_strings.last.to_coordinates.last.should eq([-3.0, -4.0])
    end

    it "raises with a MultiPoint that has a child with a wrong type" do
      decoder = WKB::BinDecoder.new
      input = "0000000005000000020000000002000000033ff000000000000040000000000000004008000000000000401000000000000040" \
              "14000000000000401800000000000000000000013ff00000000000004000000000000000"
      expect_raises(WKB::DecodeError) do
        object = decoder.decode(input)
      end
    end
  end

  context "when MultiPolygon" do
    it "decodes an empty MultiPolygon" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000600000000")
      object.should be_a(WKB::MultiPolygon)
      object.kind.multi_polygon?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic MultiPolygon" do
      decoder = WKB::BinDecoder.new
      input = "000000000600000002000000000300000001000000043ff0000000000000400000000000000040080000000000004010000000" \
              "000000401800000000000040140000000000003ff00000000000004000000000000000000000000300000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiPolygon)
      object.kind.multi_polygon?.should be_true
      multi_polygon = object.as(WKB::MultiPolygon)
      multi_polygon.polygons.size.should eq(2)
      multi_polygon.polygons.first.exterior_ring.to_coordinates[0].should eq([1.0, 2.0])
      multi_polygon.polygons.first.exterior_ring.to_coordinates[2].should eq([6.0, 5.0])
      multi_polygon.polygons.last.empty?.should be_true
    end

    it "decodes a MultiPolygon with an empty Polygon" do
      decoder = WKB::BinDecoder.new
      input = "000000000600000002000000000300000001000000043ff000000000000040000000000000004008000000000000401000" \
              "0000000000401800000000000040140000000000003ff00000000000004000000000000000000000000300000000"
      object = decoder.decode(input)
      object.should be_a(WKB::MultiPolygon)
      object.kind.multi_polygon?.should be_true
      multi_polygon = object.as(WKB::MultiPolygon)
      multi_polygon.polygons.size.should eq(2)
      multi_polygon.polygons.first.empty?.should be_false
      multi_polygon.polygons.last.empty?.should be_true
    end
  end

  context "when GeometryCollection" do
    it "decodes an empty GeometryCollection" do
      decoder = WKB::BinDecoder.new
      object = decoder.decode("000000000700000000")
      object.should be_a(WKB::GeometryCollection)
      object.kind.geometry_collection?.should be_true
      object.empty?.should be_true
    end

    it "decodes a basic GeometryCollection" do
      decoder = WKB::BinDecoder.new
      input = "0000000007000000020000000002000000033ff0000000000000400000000000000040080000000000004010000000000000" \
              "401400000000000040180000000000000000000001bff0000000000000c000000000000000"
      object = decoder.decode(input)
      object.should be_a(WKB::GeometryCollection)
      object.kind.geometry_collection?.should be_true
      geometry_collection = object.as(WKB::GeometryCollection)
      geometry_collection.geometries.size.should eq(2)
      geometry_collection.geometries.first.should be_a(WKB::LineString)
      geometry_collection.geometries.first.to_coordinates.first.should eq([1.0, 2.0])
      geometry_collection.geometries.first.to_coordinates.last.should eq([5.0, 6.0])
      geometry_collection.geometries.last.should be_a(WKB::Point)
      geometry_collection.geometries.last.to_coordinates.should eq([-1.0, -2.0])
    end
  end
end
