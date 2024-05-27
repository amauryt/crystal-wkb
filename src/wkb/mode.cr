module WKB
  enum Mode
    XY
    XYZ
    XYM
    XYZM

    # Returns the number of supported coordinates.
    def size
      case self
      in .xy?
        2
      in .xyz?, .xym?
        3
      in .xyzm?
        4
      end
    end

    # Returns `true` if the Z coordinate is supported.
    def has_z?
      self == Mode::XYZ || self == Mode::XYZM
    end

    # Returns `true` if the M coordinate is supported.
    def has_m?
      self == Mode::XYM || self == Mode::XYZM
    end

    # Returns `true` if both Z and M coordinates are supported.
    def has_zm?
      self == Mode::XYZM
    end
  end
end
