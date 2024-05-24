require "../spec_helper"

describe WKB::LineString do
  describe ".new" do
    it "creates an empty LineString" do
      line_string = WKB::LineString.new([] of Array(Float64))
      line_string.should be_a(WKB::LineString)
      line_string.kind.line_string?.should be_true
      line_string.empty?.should be_true
      line_string.size.should eq(0)
    end

    it "raises if the number of coordinates does not match the mode" do
      expect_raises(WKB::Error, /coordinates/) do
        WKB::LineString.new([[1.0, 2.0, 3.0]])
      end
    end

    it "creates a LineString with default mode XY and zero SRID" do
      line_string = WKB::LineString.new([[1.0, 2.0]])
      line_string.empty?.should be_false
      line_string.mode.xy?.should be_true
      line_string.size.should eq(1)
      line_string.srid.should eq(0)
      line_string.positions.first.size.should eq(2)
    end

    it "creates a LineString with custom mode" do
      line_string = WKB::LineString.new([[1.0, 2.0, 3.0]], WKB::Mode::XYZ)
      line_string.empty?.should be_false
      line_string.mode.xyz?.should be_true
      line_string.size.should eq(1)
      line_string.positions.first.size.should eq(3)
    end

    it "creates a LineString with custom SRID" do
      srid = 4326
      line_string = WKB::LineString.new([[1.0, 2.0]], srid: srid)
      line_string.srid.should eq(srid)
    end
  end

  describe "#closed?" do
    it "returns true for an empty LineString" do
      line_string = WKB::LineString.new([] of Array(Float64))
      line_string.closed?.should be_true
    end

    it "returns true for same begin and end coordinates" do
      line_string = WKB::LineString.new([[1.0, 2.0], [1.0, 2.0]])
      line_string.closed?.should be_true
    end
  end

  describe "#ring?" do
    it "returns false for emptu LineString" do
      line_string = WKB::LineString.new([] of Array(Float64))
      line_string.ring?.should be_false
    end

    it "returns false for same begin and end coordinates but with less than 4 elements" do
      line_string = WKB::LineString.new([[1.0, 2.0], [1.0, 2.0]])
      line_string.ring?.should be_false
    end

    it "returns false for different begin and end coordinates" do
      line_string = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0]])
      line_string.ring?.should be_false
    end

    it "returns false for same begin and end coordinates" do
      line_string = WKB::LineString.new([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [1.0, 2.0]])
      line_string.ring?.should be_true
    end
  end

  describe "#to_coordinates" do
    it "creates an empty array if empty" do
      line_string = WKB::LineString.new([] of Array(Float64))
      array = line_string.to_coordinates
      array.should be_a(Array(Array(Float64)))
      array.empty?.should be_true
    end

    it "creates an array of coordinates" do
      coordinate_array = [[1.0, 2.0]]
      line_string = WKB::LineString.new(coordinate_array)
      array = line_string.to_coordinates
      array.should be_a(Array(Array(Float64)))
      array.should eq(coordinate_array)
    end
  end

  context "indexable" do
    it "is indexable" do
      coordinate_array = [[1.0, 2.0], [3.0, 4.0]]
      line_string = WKB::LineString.new(coordinate_array)
      line_string.is_a?(Indexable(WKB::Point))
      line_string.first.x.should eq(1.0)
      line_string.last.y.should eq(4.0)
    end
  end
end
