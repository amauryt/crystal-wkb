require "../spec_helper"

describe WKB::MultiPoint do
  describe ".new" do
    it "creates an empty MultiPoint" do
      multi_point = WKB::MultiPoint.new([] of Array(Float64))
      multi_point.should be_a(WKB::MultiPoint)
      multi_point.kind.multi_point?.should be_true
      multi_point.empty?.should be_true
      multi_point.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the mode" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::MultiPoint.new([[1.0, 2.0, 3.0]])
      end
    end

    it "creates a MultiPoint with default mode XY and zero SRID" do
      multi_point = WKB::MultiPoint.new([[1.0, 2.0]])
      multi_point.empty?.should be_false
      multi_point.mode.xy?.should be_true
      multi_point.size.should eq(1)
      multi_point.srid.should eq(0)
      multi_point.points.first.mode.size.should eq(2)
    end

    it "creates a MultiPoint with custom mode" do
      multi_point = WKB::MultiPoint.new([[1.0, 2.0, 3.0]], WKB::Mode::XYZ)
      multi_point.empty?.should be_false
      multi_point.mode.xyz?.should be_true
      multi_point.size.should eq(1)
      multi_point.points.first.mode.size.should eq(3)
    end

    it "creates a MultiPoint with custom SRID" do
      srid = 4326
      multi_point = WKB::MultiPoint.new([[1.0, 2.0]], srid: srid)
      multi_point.srid.should eq(srid)
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      multi_point = WKB::MultiPoint.new([] of Array(Float64))
      array = multi_point.to_coordinates
      array.should be_a(Array(Array(Float64)))
      array.empty?.should be_true
    end

    it "creates an array of coordinates" do
      coordinate_array = [[1.0, 2.0]]
      multi_point = WKB::MultiPoint.new(coordinate_array)
      array = multi_point.to_coordinates
      array.should be_a(Array(Array(Float64)))
      array.should eq(coordinate_array)
    end
  end
end
