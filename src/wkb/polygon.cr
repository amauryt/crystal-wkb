require "./line_string_sequenceable"

module WKB
  struct Polygon < Geometry
    include LineStringSequenceable

    def rings
      @line_strings
    end

    def exterior_ring : LineString
      @line_strings.first
    end

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
