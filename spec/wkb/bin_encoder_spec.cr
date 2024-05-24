require "../spec_helper"

# Most test data taken from:
# https://github.com/rgeo/rgeo/blob/main/test/wkrep/wkb_generator_test.rb

private macro encoding_should_eq_test_str
  encoder.encode(object).to_unsafe_bytes.hexstring.should eq(test_str)
end

describe WKB::BinEncoder do
  describe "byte format" do
    it "encodes with format System (Little) Endian" do
      encoder = WKB::BinEncoder.new
      object = WKB::Point.new([1.0, 2.0])
      test_str = "0101000000000000000000f03f0000000000000040"
      encoding_should_eq_test_str
    end

    it "decodes with format Network (Big) Endian" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::Point.new([1.0, 2.0])
      test_str = "00000000013ff00000000000004000000000000000"
      encoding_should_eq_test_str
    end
  end

  context "when Point" do
    it "encodes an empty Point" do
      encoder = WKB::BinEncoder.new
      object = WKB::Point.new([] of Float64)
      test_str = "0101000000000000000000f87f000000000000f87f"
      encoding_should_eq_test_str
    end

    describe "Basic flavor" do
      it "raises when use with a mode other than XY" do
        encoder = WKB::BinEncoder.new
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        expect_raises(WKB::EncodeError) do
          encoder.encode(object)
        end
      end
    end

    describe "Ext flavor" do
      it "encodes EWKB with Z" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        test_str = "00800000013ff000000000000040000000000000004008000000000000"
        encoding_should_eq_test_str
      end

      it "encodes EWKB with M" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
        test_str = "00400000013ff000000000000040000000000000004008000000000000"
        encoding_should_eq_test_str
      end

      it "encodes EWKB with ZM" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::Ext)
        object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
        test_str = "00c00000013ff0000000000000400000000000000040080000000000004010000000000000"
        encoding_should_eq_test_str
      end

      it "encodes EWKB with SRID" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ExtSRID)
        object = WKB::Point.new([1.0, 2.0], srid: 1000)
        test_str = "0020000001000003e83ff00000000000004000000000000000"
        encoding_should_eq_test_str
      end
    end

    describe "ISO flavor" do
      it "encodes ISO with Z" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
        test_str = "00000003e93ff000000000000040000000000000004008000000000000"
        encoding_should_eq_test_str
      end

      it "encodes ISO with M" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYM)
        test_str = "00000007d13ff000000000000040000000000000004008000000000000"
        encoding_should_eq_test_str
      end

      it "encodes ISO with ZM" do
        encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ISO)
        object = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
        test_str = "0000000bb93ff0000000000000400000000000000040080000000000004010000000000000"
        encoding_should_eq_test_str
      end
    end
  end

  context "when LineString" do
    it "encodes an empty LineString" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::LineString.new([] of Array(Float64))
      test_str = "000000000200000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic LineString" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
      test_str = "0000000002000000033ff00000000000004000000000000000400800000000000040100000000000004014000000000000" \
                 "4018000000000000"
      encoding_should_eq_test_str
    end

    it "encodes an EWKB LineString with Z" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::Ext)
      object = WKB::LineString.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]], WKB::Mode::XYZ)
      test_str = "0080000002000000023ff00000000000004000000000000000400800000000000040100000000000004014000000000000" \
                 "4018000000000000"
      encoding_should_eq_test_str
    end

    it "encodes an EWKB LineString with Z and SRID" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ExtSRID)
      object = WKB::LineString.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]], WKB::Mode::XYZ, srid: 1000)
      test_str = "00a0000002000003e8000000023ff0000000000000400000000000000040080000000000004010000000000000401400000" \
                 "00000004018000000000000"
      encoding_should_eq_test_str
    end

    it "encodes an ISO LineString with M" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ISO)
      object = WKB::LineString.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]], WKB::Mode::XYM)
      test_str = "00000007d2000000023ff00000000000004000000000000000400800000000000040100000000000004014000000000000" \
                 "4018000000000000"
      encoding_should_eq_test_str
    end
  end

  context "when Polygon" do
    it "encodes an empty Polygon" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::Polygon.new([] of Array(Array(Float64)))
      test_str = "000000000300000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic Polygon" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::Polygon.new([[[1.0, 2.0], [3.0, 4.0], [6.0, 5.0], [1.0, 2.0]]])
      test_str = "000000000300000001000000043ff00000000000004000000000000000400800000000000040100000000000004018000000" \
                 "00000040140000000000003ff00000000000004000000000000000"
      encoding_should_eq_test_str
    end
  end

  context "when MultiPoint" do
    it "encodes an empty MultiPoint" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiPoint.new([] of Array(Float64))
      test_str = "000000000400000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic MultiPoint" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiPoint.new([[1.0, 2.0], [3.0, 4.0]])
      test_str = "00000000040000000200000000013ff00000000000004000000000000000000000000140080000000000004010000000000000"
      encoding_should_eq_test_str
    end

    it "encodes an EWKB MultiPoint with SRID" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian, flavor: WKB::Flavor::ExtSRID)
      object = WKB::MultiPoint.new([[1.0, 2.0], [3.0, 4.0]], srid: 1000)
      test_str = "0020000004000003e80000000200000000013ff0000000000000400000000000000000000000014008000000000000" \
                 "4010000000000000"
      encoding_should_eq_test_str
    end
  end

  context "when MultiLineString" do
    it "encodes an empty MultiLineString" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiLineString.new([] of Array(Array(Float64)))
      test_str = "000000000500000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic MultiLineString" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiLineString.new([[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]], [[-1.0, -2.0], [-3.0, -4.0]]])
      test_str = "0000000005000000020000000002000000033ff0000000000000400000000000000040080000000000004010000000000000" \
                 "40140000000000004018000000000000000000000200000002bff0000000000000c000000000000000c008000000000000" \
                 "c010000000000000"
      encoding_should_eq_test_str
    end
  end

  context "when MultiPolygon" do
    it "encodes an empty MultiPolygon" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiPolygon.new([] of Array(Array(Array(Float64))))
      test_str = "000000000600000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic MultiPolygon" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::MultiPolygon.new([
        [[[30.0, 20.0], [45.0, 40.0], [10.0, 40.0], [30.0, 20.0]]],
        [[[15.0, 5.0], [40.0, 10.0], [10.0, 20.0], [5.0, 10.0], [15.0, 5.0]]],
      ])
      test_str = "00000000060000000200000000030000000100000004403e0000000000004034000000000000404680000000000040440000" \
                 "0000000040240000000000004044000000000000403e000000000000403400000000000000000000030000000100000005402e0000000000004014000000000000404400000000000040240000000000004024000000000000403400000000000040140000000000004024000000000000402e0000000000004014000000000000"
      encoding_should_eq_test_str
    end

    it "encodes a MultiPolygon with normal and empty children" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      test_str = "000000000600000002000000000300000001000000043ff000000000000040000000000000004008000000000000401000" \
                 "0000000000401800000000000040140000000000003ff00000000000004000000000000000000000000300000000"
      object = WKB::BinDecoder.new.decode(test_str)
      encoding_should_eq_test_str
    end
  end

  context "when GeometryCollection" do
    it "encodes an empty GeometryCollection" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::GeometryCollection.new([] of WKB::Geometry)
      test_str = "000000000700000000"
      encoding_should_eq_test_str
    end

    it "encodes a basic GeometryCollection" do
      encoder = WKB::BinEncoder.new(format: IO::ByteFormat::BigEndian)
      object = WKB::GeometryCollection.new([
        WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]),
        WKB::Point.new([-1.0, -2.0]),
      ])
      test_str = "0000000007000000020000000002000000033ff0000000000000400000000000000040080000000000004010000000000000" \
                 "401400000000000040180000000000000000000001bff0000000000000c000000000000000"
      encoding_should_eq_test_str
    end
  end
end
