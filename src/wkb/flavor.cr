module WKB
  # Serialization flavors of Well-Known Binary and Well-Known Text.
  enum Flavor
    # Basic standard with support only for XY.
    Basic
    # Extended flavor used by PostGIS without SRID.
    Ext
    # Extended flavor used by PostGIS witht SRID.
    ExtSRID
    # Higher-dimensional standard as defined in ISO 13249-3
    ISO
  end
end
