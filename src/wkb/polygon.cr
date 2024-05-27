require "./line_string_sequenceable"

module WKB
  struct Polygon < Geometry
    include LineStringSequenceable

    # Returns the polygon's child line strings.
    def rings
      @line_strings
    end

    # Returns the polygon's first line string.
    def exterior_ring : LineString
      @line_strings.first
    end

    # Returns a potentially empty array with the polygon's last line strings.
    def interior_rings : Array(LineString)
      @line_strings[1..]
    end

    protected def validate_initialization
      unless @line_strings.empty?
        unless @line_strings.all?(&.ring?)
          raise WKB::Error.new("The line strings of a Polygon must be rings")
        end
      end
    end
  end
end
