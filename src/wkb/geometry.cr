require "./object"

module WKB
  abstract struct Geometry < Object
    # Returns a representation of coordinates as a nested array.
    abstract def to_coordinates
  end
end
