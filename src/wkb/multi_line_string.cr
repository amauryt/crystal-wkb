require "./line_string_sequenceable"

module WKB
  struct MultiLineString < Geometry
    include LineStringSequenceable

    protected def validate_initialization
      unless @line_strings.empty?
        if @line_strings.any? { |ls| ls.size == 1 }
          raise WKB::Error.new("The line strings of a MultiLineString cannot have only one point")
        end
      end
    end
  end
end
