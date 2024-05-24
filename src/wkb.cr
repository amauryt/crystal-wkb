require "./wkb/error"
require "./wkb/mode"
require "./wkb/object_kind"
require "./wkb/position"
require "./wkb/object"
require "./wkb/geometry"
require "./wkb/point"
require "./wkb/line_string"
require "./wkb/polygon"
require "./wkb/multi_point"
require "./wkb/multi_line_string"
require "./wkb/multi_polygon"
require "./wkb/geometry_collection"
require "./wkb/bin_decoder"
require "./wkb/bin_encoder"
require "./wkb/text_decoder"
require "./wkb/text_encoder"

module WKB
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
