module DviTools
  class DviRenderer
    def initialize
      @index = 0
    end

    def write_pre(dvi_bytes, comment)
      dvi_bytes << PRE
      dvi_bytes << 0x02
      dvi_bytes.concat([25400000].pack('N').unpack('C4')) # num = 25400000
      dvi_bytes.concat([473628672].pack('N').unpack('C4')) # den = 473628672
      dvi_bytes.concat([1000].pack('N').unpack('C4')) # mag = 1000
      @index += 14
      comment_length = comment.size
      dvi_bytes << comment_length
      dvi_bytes.concat(comment.each_char.collect { |c| c.ord })
      @index += comment_length+1
    end

    def write_page(dvi_bytes)
      dvi_bytes << BOP
      @index += 1
      10.times { dvi_bytes.concat([0].pack('N').unpack('C4')) } # c_0 to c_9
      @index += 40
      dvi_bytes.concat([-1].pack('N').unpack('C4')) # pointer to previous page; first one -1.
      @index += 4
      dvi_bytes << PUSH
      dvi_bytes << DOWN3
      # 3 bytes f2 00 00
      #  dvi_bytes << "\xf2"
      dvi_bytes << 0xf2
      dvi_bytes.concat([0x00, 0x00])
      @index += 5

      dvi_bytes << POP
      dvi_bytes << DOWN4
      # 4 bytes 02 83 33 da
      dvi_bytes << 0x02
      dvi_bytes.concat([0x83,0x33,0xda])
      @index += 6
      #  dvi_bytes << "\x83\x33\xda"

      dvi_bytes << PUSH
      dvi_bytes << DOWN4
      # 4 bytes fd 86 cc 26
      dvi_bytes.concat([0xfd,0x86,0xcc,0x26])
      dvi_bytes << PUSH
      dvi_bytes << RIGHT3
      # 3 bytes 14 00 00
      dvi_bytes << 0x14
      dvi_bytes.concat([0x00, 0x00])
      @index += 11

      dvi_bytes << FONT_DEF1
      # dvi_bytes << "\x00\x4b\xf1\x60\x79\x00\x0a\x00\x00\x00\x05\x63\x6d\x72\x31\x30"
      dvi_bytes.concat([0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30])
      # # k[1], c[4], s[4], d[4], a[1], l[1], n[a+l]
      dvi_bytes << FNT_NUM1
      @index += 22

      dvi_bytes.concat('Some text'.each_char.collect { |c| c.ord })
      dvi_bytes << POP
      dvi_bytes << POP
      dvi_bytes << EOP
      @index += 12
    end

    def write_post(dvi_bytes)
      dvi_bytes << POST
      @post_byte = @index
      @index += 1
      dvi_bytes.concat([0x00,0x00,0x00,0x2a])
      dvi_bytes.concat([25400000].pack('N').unpack('C4')) # num = 25400000
      dvi_bytes.concat([473628672].pack('N').unpack('C4')) # den = 7227
      dvi_bytes.concat([1000].pack('N').unpack('C4')) # mag = 1000
      dvi_bytes.concat([0x02,0x9b,0x33,0xda])
      dvi_bytes.concat([0x01,0xd5, 0xc1,0x47])
      dvi_bytes.concat([0x00,0x02])
      dvi_bytes.concat([0x00,0x01])
      # p[4], num[4], den[4], mag[4], l[4], u[4], s[2], t[2];

      dvi_bytes << 0xf3
      # dvi_bytes << "\x00\x4b\xf1\x60\x79\x00\x0a\x00\x00\x00\x05\x63\x6d\x72\x31\x30"
      dvi_bytes.concat([0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00, 0x0a,0x00, 0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30])

    end

    def write_post_post(dvi_bytes)
      dvi_bytes << POST_POST
      dvi_bytes.concat([@post_byte].pack('N').unpack('C4'))
      # q[4], i[1]; 223's
      #dvi_bytes << "\xa7"
      dvi_bytes << 0x02
      5.times { dvi_bytes << 223 }
    end

    def render
      dvi_bytes = []
      write_pre(dvi_bytes, 'TeX output 2015 09.06:0757')
      write_page(dvi_bytes)
      write_post(dvi_bytes)
      write_post_post(dvi_bytes)
      dvi_bytes
    end

    def write(file)
      File.open(file, 'wb') do |f|
        render.each { |b| f.putc(b) }
      end
    end
  end
end
