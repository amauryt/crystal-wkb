module WKB
  enum ObjectKind : UInt32
    Point              = 1_u32
    LineString         = 2_u32
    Polygon            = 3_u32
    MultiPoint         = 4_u32
    MultiLineString    = 5_u32
    MultiPolygon       = 6_u32
    GeometryCollection = 7_u32

    def geometry?
      self != ObjectKind::GeometryCollection
    end

    def multipart?
      case self
      when ObjectKind::MultiPoint, ObjectKind::MultiLineString, ObjectKind::MultiPolygon
        true
      else
        false
      end
    end
  end
end
