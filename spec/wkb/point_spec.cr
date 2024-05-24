require "../spec_helper"

describe WKB::Point do
  describe ".new" do
    it "creates an empty Point" do
      point = WKB::Point.new([] of Float64)
      point.should be_a(WKB::Point)
      point.kind.point?.should be_true
      point.empty?.should be_true
      point.size.should eq(0)
      point.position.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the mode" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::Point.new([1.0, 2.0, 3.0])
      end
    end

    it "creates a Point with default mode XY and zero SRID" do
      point = WKB::Point.new([1.0, 2.0])
      point.empty?.should be_false
      point.x.should eq(1.0)
      point.y.should eq(2.0)
      point.z.nan?.should be_true
      point.m.nan?.should be_true
      point.mode.xy?.should be_true
      point.size.should eq(1)
      point.position.size.should eq(2)
      point.srid.should eq(0)
    end

    it "creates a Point with mode XYZ" do
      point = WKB::Point.new([1.0, 2.0, 3.0], WKB::Mode::XYZ)
      point.empty?.should be_false
      point.x.should eq(1.0)
      point.y.should eq(2.0)
      point.z.should eq(3.0)
      point.m.nan?.should be_true
      point.mode.xyz?.should be_true
      point.position.size.should eq(3)
      point.srid.should eq(0)
    end

    it "creates a Point with mode XYM" do
      point = WKB::Point.new([1.0, 2.0, 4.0], WKB::Mode::XYM)
      point.empty?.should be_false
      point.x.should eq(1.0)
      point.y.should eq(2.0)
      point.z.nan?.should be_true
      point.m.should eq(4.0)
      point.mode.xym?.should be_true
      point.position.size.should eq(3)
      point.srid.should eq(0)
    end

    it "creates a Point with mode XYZM" do
      point = WKB::Point.new([1.0, 2.0, 3.0, 4.0], WKB::Mode::XYZM)
      point.empty?.should be_false
      point.x.should eq(1.0)
      point.y.should eq(2.0)
      point.z.should eq(3.0)
      point.m.should eq(4.0)
      point.mode.xyzm?.should be_true
      point.position.size.should eq(4)
      point.srid.should eq(0)
    end

    it "creates a Point with custom SRID" do
      srid = 4326
      point = WKB::Point.new([1.0, 2.0], srid: srid)
      point.srid.should eq(srid)
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      point = WKB::Point.new([] of Float64)
      array = point.to_coordinates
      array.should be_a(Array(Float64))
      array.empty?.should be_true
    end

    it "creates an array of 2D coordinates" do
      coordinates = [1.0, 2.0]
      point = WKB::Point.new(coordinates)
      array = point.to_coordinates
      array.should be_a(Array(Float64))
      array.should eq(coordinates)
    end

    it "creates an array of 3D coordinates" do
      coordinates = [1.0, 2.0, 3.0]
      point = WKB::Point.new(coordinates, WKB::Mode::XYZ)
      array = point.to_coordinates
      array.should be_a(Array(Float64))
      array.should eq(coordinates)
    end

    it "creates an array of 4D coordinates" do
      coordinates = [1.0, 2.0, 3.0, 4.0]
      point = WKB::Point.new(coordinates, WKB::Mode::XYZM)
      array = point.to_coordinates
      array.should be_a(Array(Float64))
      array.should eq(coordinates)
    end
  end
end
