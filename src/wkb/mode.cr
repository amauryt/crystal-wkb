module WKB
  enum Mode
    XY
    XYZ
    XYM
    XYZM

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

    def has_z?
      self == Mode::XYZ || self == Mode::XYZM
    end

    def has_m?
      self == Mode::XYM || self == Mode::XYZM
    end

    def has_zm?
      self == Mode::XYZM
    end
  end
end
