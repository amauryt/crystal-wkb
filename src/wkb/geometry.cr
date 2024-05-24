require "./object"

module WKB
  abstract struct Geometry < Object
    abstract def to_coordinates
  end
end
