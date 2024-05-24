require "./mode"

module WKB
  abstract struct Object
    getter mode = Mode::XY
    getter srid = 0
    delegate :has_z?, to: @mode
    delegate :has_m?, to: @mode
    delegate :has_zm?, to: @mode

    abstract def empty?
    abstract def size
    abstract def children

    macro inherited
      {% unless @type == WKB::Geometry %}
        def kind
          ObjectKind::{{@type.name.split("::").last.id}}
        end
      {% end %}
    end
  end
end
