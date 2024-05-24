require "../spec_helper"

describe WKB::MultiPolygon do
  valid_2d_coordinates = [
    [[-10.0, -10.0], [10.0, -10.0], [10.0, 10.0], [-10.0, -10.0]],
    [[-1.0, -2.0], [3.0, -2.0], [3.0, 2.0], [-1.0, -2.0]],
  ]

  valid_3d_coordinates = [
    [[-10.0, -10.0, 0.0], [-10.0, 10.0, 0.0], [10.0, 10.0, 0.0], [-10.0, -10.0, 0.0]],
  ]

  describe ".new" do
    it "creates an empty MultiPolygon" do
      multi_polygon = WKB::MultiPolygon.new([] of Array(Array(Array(Float64))))
      multi_polygon.should be_a(WKB::MultiPolygon)
      multi_polygon.kind.multi_polygon?.should be_true
      multi_polygon.empty?.should be_true
      multi_polygon.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the mode" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::MultiPolygon.new([[[[1.0, 2.0, 3.0]]]])
      end
    end

    it "raises if a line string is not a ring" do
      expect_raises(WKB::Error, /rings/) do
        WKB::MultiPolygon.new([[[[1.0, 2.0]]]])
      end
    end

    it "creates a MultiPolygon with default mode XY and zero SRID" do
      multi_polygon = WKB::MultiPolygon.new([valid_2d_coordinates, valid_2d_coordinates])
      multi_polygon.empty?.should be_false
      multi_polygon.mode.xy?.should be_true
      multi_polygon.size.should eq(2)
      multi_polygon.srid.should eq(0)
    end

    it "creates a MultiPolygon with custom mode" do
      multi_polygon = WKB::MultiPolygon.new([valid_3d_coordinates], WKB::Mode::XYZ)
      multi_polygon.empty?.should be_false
      multi_polygon.mode.xyz?.should be_true
      multi_polygon.size.should eq(1)
    end

    it "creates a MultiPolygon with custom SRID" do
      srid = 4326
      multi_polygon = WKB::MultiPolygon.new([valid_2d_coordinates], srid: srid)
      multi_polygon.srid.should eq(srid)
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      multi_polygon = WKB::MultiPolygon.new([] of Array(Array(Array(Float64))))
      array = multi_polygon.to_coordinates
      array.should be_a(Array(Array(Array(Array(Float64)))))
      array.empty?.should be_true
    end

    it "creates an array of coordinates" do
      multi_polygon = WKB::MultiPolygon.new([valid_2d_coordinates])
      array = multi_polygon.to_coordinates
      array.should be_a(Array(Array(Array(Array(Float64)))))
      array.should eq([valid_2d_coordinates])
    end
  end
end
