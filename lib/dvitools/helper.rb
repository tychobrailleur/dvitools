module DviTools
  module Helper
    def peek(f)
      peek = f.readbyte
      f.ungetbyte(peek)
      peek
    end

    def four_byte_unsigned(f)
      a = f.getbyte
      b = f.getbyte
      c = f.getbyte
      d = f.getbyte

      (a << 24) + (b << 16) + (c << 8) + d
    end

    def three_byte_unsigned(f)
      a = f.getbyte
      b = f.getbyte
      c = f.getbyte
      (a << 16) + (b << 8) + c
    end

    def two_byte_unsigned(f)
      a = f.getbyte
      b = f.getbyte
      (a << 8)  + b
    end

    def four_byte_signed(f)
      a = f.getbyte
      b = f.getbyte
      c = f.getbyte
      d = f.getbyte
      if a < 128
        (a << 24) + (b << 16) + (c << 8) + d
      else
        ((a-256) << 24) + (b << 16) + (c << 8) + d
      end
    end

    def three_byte_signed(f)
      a = f.getbyte
      b = f.getbyte
      c = f.getbyte
      if a < 128
        (a << 16) + (b << 8) + c
      else
        ((a-256) << 16) + (b << 8) + c
      end
    end

    def two_byte_signed(f)
      a = f.getbyte
      b = f.getbyte
      if a < 128
        (a << 8)  + b
      else
        ((a-256) << 8)  + b
      end
    end
  end
end
