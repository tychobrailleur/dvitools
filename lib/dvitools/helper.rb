module DviTools
  module Helper
    def peek(f)
      peek = f.readbyte
      f.ungetbyte(peek)
      peek
    end

    def four_byte_unsigned(f)
      f.read(4).unpack('H*').first.to_i(16)
    end

    def two_byte_unsigned(f)
      f.read(2).unpack('H*').first.to_i(16)
    end


  end
end
