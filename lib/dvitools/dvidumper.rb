module DviTools
  # The +DviDumper+ parses a DVI file and prints out its structure
  # and the different opcodes used.
  class DviDumper
    include Helper

    def initialize
      @index = 0
    end

    attr_writer :out

    def dump(file)
      f = load(file)
      accept_pre(f)
      accept_page(f)
      accept_post(f)
      accept_post_post(f)
    end

    private

    def out
      @out ||= STDOUT
    end

    def load(file)
      File.open(file, 'rb')
    end

    def accept_pre(f)
      raise "not pre" unless f.readbyte == PRE
      out.puts "pre"
      out.puts "  version #{f.readbyte}"
      num = four_byte_unsigned(f)
      den = four_byte_unsigned(f)
      @mag = four_byte_unsigned(f)
      comment_size = f.readbyte
      comment = f.read(comment_size)

      out.puts "  num = #{num}"
      out.puts "  den = #{den}"
      out.puts "  mag = #{@mag}"
      out.puts "  comment = #{comment}"
      out.puts
    end

    def accept_page(f)
      raise "not page" unless f.readbyte == BOP
      out.puts "page"
      num_page = f.read(4)
      out.puts "  page #{num_page.unpack('l>')}"

      9.times { f.read(4) }

      previous_page = f.read(4).unpack("l>")
 #     out.puts "  previous page: #{previous_page}"

      buffer = ''
      while (b = f.readbyte) != EOP
        if b >= 0 && b <= 127
          buffer << b.chr
        else
          if !buffer.empty?
            out.puts "  text: #{buffer}"
            buffer = ''
          end
          if b == PUSH
            out.puts "  push"
          elsif b == POP
            out.puts "  pop"
          elsif b == DOWN4
            out.print "  down4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif b == DOWN3
            out.print "  down3: "
            d = f.read(3)
            out.puts d.unpack("l>")
          elsif b == DOWN2
            out.print "  down2: "
            d = f.read(2)
            out.puts d.unpack("s>")
          elsif b == DOWN1
            out.print "  down1: "
            d = f.read(1)
            out.puts d.unpack("l>")
          elsif b == RIGHT1
            out.print "  right1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == RIGHT2
            out.print "  right2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == RIGHT3
            out.print "  right3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == RIGHT4
            out.print "  right4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif [FONT_DEF1, FONT_DEF2, FONT_DEF3, FONT_DEF4].include?(b)
            f.ungetbyte(b)
            accept_font_definition(f)
          elsif b == FNT_NUM1
          elsif b == FNT1
            out.print "  fnt1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == FNT2
            out.print "  fnt2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == FNT3
            out.print "  fnt3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == FNT4
            out.print "  fnt4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif b == XXX1
            d = f.read(1)
          elsif b == XXX2
            d = f.read(2)
          elsif b == XXX3
            d = f.read(3)
          elsif b == XXX4
            d = f.read(4)
          elsif b == SET1
            out.print "  set1: "
            d = f.read(1)
            out.puts d
          elsif b == SET2
            out.print "  set2: "
            d = f.read(2)
            out.puts d
          elsif b == SET3
            out.print "  set3: "
            d = f.read(3)
            out.puts d
          elsif b == SET4
            out.print "  set4: "
            d = f.read(4)
          elsif b == SET_RULE
            out.print "  set_rule: "
            d = f.read(4)
            e = f.read(4)
            out.puts " #{d.unpack('l>')} #{d.unpack('l>')}"
          elsif b == PUT_RULE
            out.print "  put_rule: "
            d = f.read(4)
            e = f.read(4)
            out.puts " #{d.unpack('l>')} #{d.unpack('l>')}"
          elsif b == NOP
          elsif b == PUT1
            out.print "  put1: "
            d = f.read(1)
            out.puts d
          elsif b == PUT2
            d = f.read(2)
            out.puts d
          elsif b == PUT3
            d = f.read(3)
            out.puts d
          elsif b == PUT4
            d = f.read(4)
            out.puts d
          elsif b == W0
          elsif b == W1
            out.print "  w1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == W2
            out.print "  w2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == W3
            out.print "  w3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == W4
            out.print "  w4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif b == Y0
            out.puts "  y0"
          elsif b == Y1
            out.print "  y1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == Y2
            out.print "  y2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == Y3
            out.print "  y3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == Y4
            out.print "  y4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif b == X0
            out.puts "  x0"
          elsif b == X1
            out.print "  x1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == X2
            out.print "  x2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == X3
            out.print "  x3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == X4
            out.print "  x4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          elsif b == Z0
            out.puts "  z0"
          elsif b == Z1
            out.print "  z1: "
            d = f.read(1)
            out.puts d.unpack('l>')
          elsif b == Z2
            out.print "  z2: "
            d = f.read(2)
            out.puts d.unpack('s>')
          elsif b == Z3
            out.print "  z3: "
            d = f.read(3)
            out.puts d.unpack('l>')
          elsif b == Z4
            out.print "  z4: "
            d = f.read(4)
            out.puts d.unpack('l>')
          end
        end
      end

      out.puts "end page"
      out.puts
      accept_next_page(f)
    end

    # If the next byte is BOP, a new page is starting.
    def accept_next_page(f)
      flag = false
      peek = peek(f)
      flag = true if peek.ord == BOP

      accept_page(f) if flag
    end

    def accept_post(f)
      raise "not post" unless f.readbyte == POST
      out.puts "post"

      final_bop = f.read(4)
#      out.puts "  final bop: #{final_bop.unpack('l>')}"

      num = four_byte_unsigned(f)
      den = four_byte_unsigned(f)
      mag = four_byte_unsigned(f)

      out.puts "  num = #{num}"
      out.puts "  den = #{den}"
      out.puts "  mag = #{mag}"

      max_length = four_byte_unsigned(f)
      max_height = four_byte_unsigned(f)

      out.puts "  max length: #{max_length}"
      out.puts "  max height: #{max_height}"

      max_stack_depth = two_byte_unsigned(f)

      out.puts "  max stack depth: #{max_stack_depth}"

      total_num_page = two_byte_unsigned(f)

      out.puts "  number of pages: #{total_num_page}"
      out.puts ""

      accept_font_definition(f)
    end

    def accept_font_definition(f)
      opcode = f.readbyte
      raise "not font" unless [FONT_DEF1, FONT_DEF2, FONT_DEF3, FONT_DEF4].include?(opcode)
      out.puts "    font"
      if opcode == FONT_DEF1
        d = f.read(1)
        #puts d.unpack('c')
      elsif opcode == FONT_DEF2
        d = f.read(2)
        #puts d.unpack('s>')
      elsif opcode == FONT_DEF3
        d = f.read(3)
        #puts d.unpack('l>')
      elsif opcode == FONT_DEF4
        d = f.read(4)
        #puts d.unpack('l>')
      end

      # TFM checksum
      c = four_byte_unsigned(f)
      #puts c
      # scale factor
      s = four_byte_unsigned(f)
      #puts s
      # design size
      d = four_byte_unsigned(f)
      #puts d

      out.puts "      font size: #{@mag*s / (1000.0*d)}"

      dir_size = f.readbyte
      filename_size = f.readbyte

      dir = f.read(dir_size)
      filename = f.read(filename_size)

      out.puts "      dir: #{dir}"
      out.puts "      filename: #{filename}"

      out.puts "    end font"

      peek = peek(f)

      if [FONT_DEF1, FONT_DEF2, FONT_DEF3, FONT_DEF4].include?(peek)
        accept_font_definition(f)
      end

    end

    def accept_post_post(f)
      raise "not post post" unless f.readbyte == POST_POST
      out.puts "post_post"

      p = f.read(4)
      i = f.readbyte

      raise "incorrect version" unless i == 2

      4.times do
        trailer = f.readbyte
        raise "invalid trailer" unless trailer == TRAILER
      end

      begin
        while b = f.readbyte
          raise "invalid trailer: #{b}" unless b == TRAILER
        end
      rescue EOFError
        f.close
      end
    end
  end
end
