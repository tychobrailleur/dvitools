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
    end

    def accept_pre(f)
      raise "not pre" unless f.readbyte.ord == PRE
      puts "pre"
      puts "  version #{f.readbyte.ord}"
      num = f.read(4).unpack('H*').first.to_i(16)
      den = f.read(4).unpack('H*').first.to_i(16)
      mag = f.read(4).unpack('H*').first.to_i(16)
      comment_size = f.readbyte.ord
      comment = f.read(comment_size)

      puts "  num = #{num}"
      puts "  den = #{den}"
      puts "  mag = #{mag}"
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
      puts "  previous page: #{previous_page}"

      while (b = f.readbyte).ord != EOP
        if b == PUSH
          puts "  push"
        elsif b == POP
          puts "  pop"
        elsif b == DOWN4
          puts "  down4"
          d = f.read(4)
          puts d.unpack('l>')
        elsif b == DOWN3
          puts "  down3"
          d = f.read(3)
          puts d.unpack("l>")
        elsif b == DOWN2
          puts "  down2"
          d = f.read(2)
          puts d.unpack("l>")
        elsif b == DOWN1
          puts "  down1"
          d = f.read(1)
          puts d.unpack("l>")
        end
      end

      puts "end page" unless f.readbyte.ord != EOP
    end
  end
  # DivRenderer.new.write('/tmp/test.dvi')

  # puts DviDumper.new.dump('/tmp/example.dvi')
end
