module DviTools
  class DviDumper
    def initialize
      @index = 0
    end

    def load(file)
      File.open(file, 'rb')
    end

    def dump(file)
      f = load(file)
      accept_pre(f)
      accept_page(f)
      accept_post(f)
      accept_post_post(f)
    end

    def accept_pre(f)
      raise "not pre" unless f.readbyte.ord == PRE
      puts "pre"
      puts "  version #{f.readbyte.ord}"
      num = f.read(4).unpack('H*').first.to_i(16)
      den = f.read(4).unpack('H*').first.to_i(16)
      @mag = f.read(4).unpack('H*').first.to_i(16)
      comment_size = f.readbyte.ord
      comment = f.read(comment_size)

      puts "  num = #{num}"
      puts "  den = #{den}"
      puts "  mag = #{@mag}"
      puts "  comment = #{comment}"
      puts
    end

    def accept_page(f)
      raise "not page" unless f.readbyte.ord == BOP
      puts "page"
      num_page = f.read(4)
      puts "  page #{num_page.unpack('l>')}"

      9.times { f.read(4) }

      previous_page = f.read(4).unpack("l>")
 #     puts "  previous page: #{previous_page}"


      buffer = ''
      while (b = f.readbyte).ord != EOP
        if b >= 0 && b <= 127
          buffer << b.chr
        else
          if !buffer.empty?
            puts "  text: #{buffer}"
            buffer = ''
          end
          if b == PUSH
            puts "  push"
          elsif b == POP
            puts "  pop"
          elsif b == DOWN4
            print "  down4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == DOWN3
            print "  down3: "
            d = f.read(3)
            puts d.unpack("l>")
          elsif b == DOWN2
            print "  down2: "
            d = f.read(2)
            puts d.unpack("s>")
          elsif b == DOWN1
            print "  down1: "
            d = f.read(1)
            puts d.unpack("l>")
          elsif b == RIGHT1
            print "  right1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == RIGHT2
            print "  right2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == RIGHT3
            print "  right3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == RIGHT4
            print "  right4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == FONT_DEF1
            f.ungetbyte(b)
            accept_font_definition(f)
          elsif b == FONT_DEF2
            f.ungetbyte(b)
            accept_font_definition(f)
          elsif b == FONT_DEF3
            f.ungetbyte(b)
            accept_font_definition(f)
          elsif b == FONT_DEF4
            f.ungetbyte(b)
            accept_font_definition(f)
          elsif b == FNT_NUM1
          elsif b == FNT1
            print "  fnt1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == FNT2
            print "  fnt2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == FNT3
            print "  fnt3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == FNT4
            print "  fnt4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == XXX1
            d = f.read(1)
          elsif b == XXX2
            d = f.read(2)
          elsif b == XXX3
            d = f.read(3)
          elsif b == XXX4
            d = f.read(4)
          elsif b == W0
          elsif b == W1
            print "  w1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == W2
            print "  w2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == W3
            print "  w3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == W4
            print "  w4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == Y0
            puts "  y0"
          elsif b == Y1
            print "  y1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == Y2
            print "  y2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == Y3
            print "  y3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == Y4
            print "  y4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == X0
            puts "  x0"
          elsif b == X1
            print "  x1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == X2
            print "  x2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == X3
            print "  x3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == X4
            print "  x4: "
            d = f.read(4)
            puts d.unpack('l>')
          elsif b == Z0
            puts "  z0"
          elsif b == Z1
            print "  z1: "
            d = f.read(1)
            puts d.unpack('l>')
          elsif b == Z2
            print "  z2: "
            d = f.read(2)
            puts d.unpack('s>')
          elsif b == Z3
            print "  z3: "
            d = f.read(3)
            puts d.unpack('l>')
          elsif b == Z4
            print "  z4: "
            d = f.read(4)
            puts d.unpack('l>')
          end
        end
      end

      puts "end page"
      puts ""
      accept_next_page(f)
    end

    def accept_next_page(f)
      flag = false
      peek = f.readbyte
      flag = true if peek.ord == BOP

      f.ungetbyte(peek)

      accept_page(f) if flag
    end

    def accept_post(f)
      raise "not post" unless f.readbyte.ord == POST
      puts "post"

      final_bop = f.read(4)
#      puts "  final bop: #{final_bop.unpack('l>')}"

      num = f.read(4).unpack('H*').first.to_i(16)
      den = f.read(4).unpack('H*').first.to_i(16)
      mag = f.read(4).unpack('H*').first.to_i(16)

      puts "  num = #{num}"
      puts "  den = #{den}"
      puts "  mag = #{mag}"

      max_length = f.read(4).unpack('H*').first.to_i(16)
      max_height = f.read(4).unpack('H*').first.to_i(16)

      puts "  max length: #{max_length}"
      puts "  max height: #{max_height}"

      max_stack_depth = f.read(2).unpack('H*').first.to_i(16)

      puts "  max stack depth: #{max_stack_depth}"

      total_num_page = f.read(2).unpack('H*').first.to_i(16)

      puts "  number of pages: #{total_num_page}"
      puts ""

      accept_font_definition(f)

    end

    def accept_font_definition(f)
      opcode = f.readbyte
      raise "not font" unless [FONT_DEF1, FONT_DEF2, FONT_DEF3, FONT_DEF4].include?(opcode.ord)
      puts "    font"
      if opcode.ord == FONT_DEF1
        d = f.read(1)
        #puts d.unpack('c')
      elsif opcode.ord == FONT_DEF2
        d = f.read(2)
        #puts d.unpack('s>')
      elsif opcode.ord == FONT_DEF3
        d = f.read(3)
        #puts d.unpack('l>')
      elsif opcode.ord == FONT_DEF4
        d = f.read(4)
        #puts d.unpack('l>')
      end

      # TFM checksum
      c = f.read(4).unpack('H*').first.to_i(16)
      #puts c
      # scale factor
      s = f.read(4).unpack('H*').first.to_i(16)
      #puts s
      # design size
      d = f.read(4).unpack('H*').first.to_i(16)
      #puts d

      puts "      font size: #{@mag*s / (1000.0*d)}"

      dir_size = f.readbyte.ord
      filename_size = f.readbyte.ord

      dir = f.read(dir_size)
      filename = f.read(filename_size)

      puts "      dir: #{dir}"
      puts "      filename: #{filename}"

      puts "    end font"

      peek = f.readbyte
      f.ungetbyte(peek)

      if [FONT_DEF1, FONT_DEF2, FONT_DEF3, FONT_DEF4].include?(peek.ord)
        accept_font_definition(f)
      end

    end

    def accept_post_post(f)
      raise "not post post" unless f.readbyte.ord == POST_POST
      puts "post_post"

      p = f.read(4)
      i = f.readbyte.ord

      raise "incorrect version" unless i == 2

      4.times do
        trailer = f.readbyte.ord
        raise "invalid trailer" unless trailer == TRAILER
      end

      while (b = f.read) != ''
        raise "invalid trailer" unless b.ord == TRAILER
      end

    end
  end
end
