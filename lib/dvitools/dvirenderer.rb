module DviTools
  class DviRenderer
    def initialize
      @index = 0
      @page = 0
      @last_bop = -1
    end

    def write_pre(dvi_bytes)
      dvi_bytes << PRE
      dvi_bytes << 0x02
      dvi_bytes.concat([@dvidoc.num].pack('N').unpack('C4')) # num = 25400000
      dvi_bytes.concat([@dvidoc.den].pack('N').unpack('C4')) # den = 473628672
      dvi_bytes.concat([@dvidoc.mag].pack('N').unpack('C4')) # mag = 1000
      @index += 14
      comment = @dvidoc.comment
      comment_length = comment.size
      dvi_bytes << comment_length
      dvi_bytes.concat(comment.each_char.collect { |c| c.ord })
      @index += comment_length+1
    end

    def write_stack(dvi_bytes)
      dvi_bytes << PUSH
      @index += 1
      yield dvi_bytes
      dvi_bytes << POP
      @index += 1
    end

    def write_page(dvi_bytes, page_content)
      dvi_bytes << BOP
      last_bop = @index
      @index += 1
      @page += 1
      dvi_bytes.concat([@page].pack('N').unpack('C4')) # c0 = page
      9.times { dvi_bytes.concat([0].pack('N').unpack('C4')) } # c_1 to c_9
      @index += 40
      dvi_bytes.concat([@last_bop].pack('N').unpack('C4')) # pointer to previous page
      @last_bop = last_bop
      @index += 4
      write_stack(dvi_bytes) do |a|
        a << DOWN3
        # 3 bytes f2 00 00
        a.concat([0xf2, 0x00, 0x00])
        @index += 4
      end
      dvi_bytes << DOWN4
      # 4 bytes 02 83 33 da
      dvi_bytes.concat([0x02, 0x83,0x33,0xda])
      @index += 5

      write_stack(dvi_bytes) do |a|
        a << DOWN4
        # 4 bytes fd 86 cc 26
        a.concat([0xfd,0x86,0xcc,0x26])
        @index += 5
        write_stack(a) do |aa|
          aa << RIGHT3
          # 3 bytes 14 00 00
          aa.concat([0x14, 0x00, 0x00])
          @index += 4

          aa << FONT_DEF1
          aa.concat([0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30])
          # # k[1], c[4], s[4], d[4], a[1], l[1], n[a+l]
          aa << FNT_NUM1
          @index += 22

          aa.concat(page_content.each_char.collect { |c| c.ord })
          @index += page_content.size
        end
      end
      dvi_bytes << EOP
      @index += 1
    end

    def write_post(dvi_bytes)
      dvi_bytes << POST
      @post_byte = @index
      @index += 1
      dvi_bytes.concat([@last_bop].pack('N').unpack('C4'))
      dvi_bytes.concat([@dvidoc.num].pack('N').unpack('C4')) # num = 25400000
      dvi_bytes.concat([@dvidoc.den].pack('N').unpack('C4')) # den = 473628672
      dvi_bytes.concat([@dvidoc.mag].pack('N').unpack('C4')) # mag = 1000
      dvi_bytes.concat([0x02,0x9b,0x33,0xda])
      dvi_bytes.concat([0x01,0xd5, 0xc1,0x47])
      dvi_bytes.concat([0x00,0x02])
      dvi_bytes.concat([@page].pack('n').unpack('C2'))
      # p[4], num[4], den[4], mag[4], l[4], u[4], s[2], t[2];

      dvi_bytes << FONT_DEF1
      dvi_bytes.concat([0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00, 0x0a,0x00, 0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30])

    end

    def write_post_post(dvi_bytes)
      dvi_bytes << POST_POST
      dvi_bytes.concat([@post_byte].pack('N').unpack('C4'))
      # q[4], i[1]; 223's
      dvi_bytes << 0x02
      5.times { dvi_bytes << TRAILER }
    end

    def render(dvidoc)
      @dvidoc = dvidoc
      dvi_bytes = []
      write_pre(dvi_bytes)
      @dvidoc.pages.each { |p| write_page(dvi_bytes, p) }
      write_post(dvi_bytes)
      write_post_post(dvi_bytes)
      dvi_bytes
    end

    def write(dvidoc, file)
      File.open(file, 'wb') do |f|
        render(dvidoc).each { |b| f.putc(b) }
      end
    end
  end
end
