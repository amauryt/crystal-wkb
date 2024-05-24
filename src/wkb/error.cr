module WKB
  class Error < Exception
  end

  class DecodeError < WKB::Error
  end

  class EncodeError < WKB::Error
  end
end
