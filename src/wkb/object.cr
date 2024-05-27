require "./mode"

module WKB
  abstract struct Object
    # Returns the object's coordinate mode.
    getter mode = Mode::XY
    # Returns the object's SRID.
    getter srid = 0

    # Returns `true` if the Z coordinate is supported.
    def has_z?
      @mode.has_z?
    end

    # Returns `true` if the M coordinate is supported.
    def has_m?
      @mode.has_m?
    end

    # Returns `true` if both Z and M coordinates are supported.
    def has_zm?
      @mode.has_zm?
    end

    # Returns the object's child entities as an array.
    abstract def children
    # Returns the size of the object's children.
    abstract def size
    # Returns `true` if the object has no children.
    abstract def empty?

    macro inherited
      {% unless @type == WKB::Geometry %}
        def kind : ObjectKind
          ObjectKind::{{@type.name.split("::").last.id}}
        end
      {% end %}
    end
  end
end
