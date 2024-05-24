require "../spec_helper"

describe WKB::GeometryCollection do
  describe ".new" do
    it "creates an empty GeometryCollection" do
      geometry_collection = WKB::GeometryCollection.new([] of WKB::Geometry)
      geometry_collection.should be_a(WKB::GeometryCollection)
      geometry_collection.kind.geometry_collection?.should be_true
      geometry_collection.empty?.should be_true
      geometry_collection.size.should eq(0)
    end

    it "creates a Geometry Collection" do
      point = WKB::Point.new([1.0, 2.0])
      line_string = WKB::LineString.new([[3.0, 4.0], [5.0, 6.0]])
      geometry_collection = WKB::GeometryCollection.new([point, line_string])
      geometry_collection.size.should eq(2)
    end

    context "child geometries consistency" do
      point = WKB::Point.new([1.0, 2.0])
      line_string = WKB::LineString.new([[3.0, 4.0], [5.0, 6.0]])

      it "raises if the mode of one child does not match" do
        geometries = [point, line_string]
        expect_raises(WKB::Error, /mode/) do
          WKB::GeometryCollection.new(geometries, WKB::Mode::XYZ)
        end
      end

      it "raises if the SRID of one child does not match" do
        geometries = [point, line_string]
        expect_raises(WKB::Error, /SRID/) do
          WKB::GeometryCollection.new(geometries, srid: 4326)
        end
      end
    end
  end

  describe "#to_a" do
    it "creates an empty array if empty" do
      # geometry_collection = WKB::GeometryCollection.new([] of WKB::Geometry)
      # array = geometry_collection.to_a
      # array.should be_a(Array(WKB::Geometry))
      # array.empty?.should be_true
    end

    it "creates an array of geometries" do
      # point = WKB::Point.new([1.0, 2.0])
      # line_string = WKB::LineString.new([[3.0, 4.0], [5.0, 6.0]])
      # geometry_collection = WKB::GeometryCollection.new([point, line_string])
      # array = geometry_collection.to_a
      # array.should be_a(Array(WKB::Geometry))
      # array.should be(geometry_collection.geometries)
      # array.should eq([point, line_string])
    end
  end
end
