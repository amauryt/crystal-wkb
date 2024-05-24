require "../spec_helper"

describe WKB::MultiLineString do
  valid_2d_coordinates = [
    [[-10.0, -10.0], [10.0, -10.0], [10.0, 10.0], [-10.0, -10.0]],
    [[-1.0, -2.0], [3.0, -2.0], [3.0, 2.0], [-1.0, -2.0]],
  ]

  valid_3d_coordinates = [
    [[-10.0, -10.0, 0.0], [-10.0, 10.0, 0.0], [10.0, 10.0, 0.0], [-10.0, -10.0, 0.0]],
  ]

  describe ".new" do
    it "creates an empty MultiLineString" do
      multi_line_string = WKB::MultiLineString.new([] of Array(Array(Float64)))
      multi_line_string.should be_a(WKB::MultiLineString)
      multi_line_string.kind.multi_line_string?.should be_true
      multi_line_string.empty?.should be_true
      multi_line_string.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the dimension model" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::MultiLineString.new([[[1.0, 2.0, 3.0]]])
      end
    end

    it "raises if a line string has only one point" do
      expect_raises(WKB::Error, /one point/) do
        WKB::MultiLineString.new([[[1.0, 2.0]]])
      end
    end

    it "creates a MultiLineString with default dimension model XY and zero SRID" do
      multi_line_string = WKB::MultiLineString.new(valid_2d_coordinates)
      multi_line_string.empty?.should be_false
      multi_line_string.mode.xy?.should be_true
      multi_line_string.size.should eq(2)
      multi_line_string.srid.should eq(0)
      multi_line_string.line_strings.first.to_coordinates.first.size.should eq(2)
    end

    it "creates a MultiLineString with custom dimension model" do
      multi_line_string = WKB::MultiLineString.new(valid_3d_coordinates, WKB::Mode::XYZ)
      multi_line_string.empty?.should be_false
      multi_line_string.mode.xyz?.should be_true
      multi_line_string.size.should eq(1)
      multi_line_string.line_strings.first.to_coordinates.first.size.should eq(3)
    end

    it "creates a MultiLineString with custom SRID" do
      srid = 4326
      multi_line_string = WKB::MultiLineString.new(valid_2d_coordinates, srid: srid)
      multi_line_string.srid.should eq(srid)
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      multi_line_string = WKB::MultiLineString.new([] of Array(Array(Float64)))
      array = multi_line_string.to_coordinates
      array.should be_a(Array(Array(Array(Float64))))
      array.empty?.should be_true
    end

    it "creates an array of coordinates" do
      multi_line_string = WKB::MultiLineString.new(valid_2d_coordinates)
      array = multi_line_string.to_coordinates
      array.should be_a(Array(Array(Array(Float64))))
      array.should eq(valid_2d_coordinates)
    end
  end
end
