require "../spec_helper"

describe WKB::Polygon do
  valid_2d_coordinates = [
    [[-10.0, -10.0], [10.0, -10.0], [10.0, 10.0], [-10.0, -10.0]],
    [[-1.0, -2.0], [3.0, -2.0], [3.0, 2.0], [-1.0, -2.0]],
  ]

  valid_3d_coordinates = [
    [[-10.0, -10.0, 0.0], [-10.0, 10.0, 0.0], [10.0, 10.0, 0.0], [-10.0, -10.0, 0.0]],
  ]

  describe ".new" do
    it "creates an empty Polygon" do
      polygon = WKB::Polygon.new([] of Array(Array(Float64)))
      polygon.should be_a(WKB::Polygon)
      polygon.kind.polygon?.should be_true
      polygon.empty?.should be_true
      polygon.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the dimension model" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::Polygon.new([[[1.0, 2.0, 3.0]]])
      end
    end

    it "raises if the a line string has less than four coordinates" do
      expect_raises(WKB::Error, /rings/) do
        WKB::Polygon.new([[[1.0, 2.0]]])
      end
    end

    it "raises if the a line string is not a ring" do
      expect_raises(WKB::Error, /rings/) do
        WKB::Polygon.new([[[1.0, 2.0], [3.0, 1.0], [2.0, 1.0], [0.0, 0.0]]])
      end
    end

    it "creates a Polygon with default dimension model XY and zero SRID" do
      polygon = WKB::Polygon.new(valid_2d_coordinates)
      polygon.empty?.should be_false
      polygon.mode.xy?.should be_true
      polygon.size.should eq(2)
      polygon.srid.should eq(0)
      polygon.line_strings.first.to_coordinates.first.size.should eq(2)
    end

    it "creates a Polygon with custom dimension model" do
      polygon = WKB::Polygon.new(valid_3d_coordinates, WKB::Mode::XYZ)
      polygon.empty?.should be_false
      polygon.mode.xyz?.should be_true
      polygon.size.should eq(1)
      polygon.line_strings.first.to_coordinates.first.size.should eq(3)
    end

    it "creates a Polygon with custom SRID" do
      srid = 4326
      polygon = WKB::Polygon.new(valid_2d_coordinates, srid: srid)
      polygon.srid.should eq(srid)
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      polygon = WKB::Polygon.new([] of Array(Array(Float64)))
      array = polygon.to_coordinates
      array.should be_a(Array(Array(Array(Float64))))
      array.empty?.should be_true
    end

    it "creates an array of coordinates" do
      polygon = WKB::Polygon.new(valid_2d_coordinates)
      array = polygon.to_coordinates
      array.should be_a(Array(Array(Array(Float64))))
      array.should eq(valid_2d_coordinates)
    end
  end

  context "Polygon rings" do
    polygon = WKB::Polygon.new(valid_2d_coordinates)

    describe "#rings" do
      it "returns the polygon's line strings" do
        polygon.rings.should be(polygon.line_strings)
      end
    end

    describe "#exterior_ring" do
      it "returns the first line string" do
        polygon.exterior_ring.should be_a(WKB::LineString)
        polygon.exterior_ring.to_coordinates.should eq(valid_2d_coordinates.first)
      end
    end

    describe "#interior_rings" do
      it "returns the last line strings" do
        polygon.interior_rings.should be_a(Array(WKB::LineString))
        polygon.interior_rings.map(&.to_coordinates).should eq([valid_2d_coordinates.last])
      end
    end
  end
end
