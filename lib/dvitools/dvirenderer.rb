module DviTools
  class DviRenderer
    def write_pre(dvi_bytes, comment)
      dvi_bytes << [0xf7].pack('C') # pre opcode
      dvi_bytes << [0x02].pack('C') # version 2
      dvi_bytes << [25400000].pack('N') # num = 25400000
      #dvi_bytes << [7227].pack('N') # den = 7227
      dvi_bytes << [285900].pack('N') # den = 285900 ???
      dvi_bytes << [1000].pack('N') # mag = 1000
      comment_length = comment.size
      dvi_bytes << [comment_length].pack('C')
      dvi_bytes << comment
    end

    def write_page(dvi_bytes)
      dvi_bytes << [0x8b].pack('C') # bop opcode
      10.times { dvi_bytes << [0].pack('N') } # c_0 to c_9
      dvi_bytes << [-1].pack('N') # pointer to previous page; first one -1.
      dvi_bytes << [0x8d].pack('C') # push
      dvi_bytes << [0x9f].pack('C') # down3
      # 3 bytes f2 00 00
      #  dvi_bytes << "\xf2"
      dvi_bytes << [0xf2].pack('C')
      dvi_bytes << [0x00, 0x00].pack('CC')

      dvi_bytes << [0x8e].pack('C') # pop
      dvi_bytes << [0xa0].pack('C') # down4
      # 4 bytes 02 83 33 da
      dvi_bytes << [0x02].pack('C')
      dvi_bytes << [0x83,0x33,0xda].pack('CCC')
      #  dvi_bytes << "\x83\x33\xda"

      dvi_bytes << [0x8d].pack('C') # push
      dvi_bytes << [0xa0].pack('C') # down4
      # 4 bytes fd 86 cc 26
      dvi_bytes << [0xfd,0x86,0xcc,0x26].pack('CCCC') #"\xfd\x86\xcc\x26"
      dvi_bytes << [0x8d].pack('C') # push
      dvi_bytes << [0x91].pack('C') # right3
      # 3 bytes 14 00 00
      dvi_bytes << [0x14].pack('C')
      dvi_bytes << [0x00, 0x00].pack('CC')

      dvi_bytes << [0xf3].pack('C') # fnt_def1
      # dvi_bytes << "\x00\x4b\xf1\x60\x79\x00\x0a\x00\x00\x00\x05\x63\x6d\x72\x31\x30"
      dvi_bytes << [0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30].pack('C*')
      # # k[1], c[4], s[4], d[4], a[1], l[1], n[a+l]
      dvi_bytes << [0xab].pack('C') # fnt_num1

      dvi_bytes << 'Some text'
      dvi_bytes << [0x8e].pack('C') # pop
      dvi_bytes << [0x8e].pack('C') # pop
      dvi_bytes << [0x8c].pack('C') # eop opcode
    end

    def write_post(dvi_bytes)
      dvi_bytes << [0xf8].pack('C')
      dvi_bytes << [0x00,0x00,0x00,0x2a].pack('C*') # p[4]
      dvi_bytes << [25400000].pack('N') # num = 25400000
      dvi_bytes << [7227].pack('N') # den = 7227
      dvi_bytes << [1000].pack('N') # mag = 1000
      dvi_bytes << [0x02,0x9b,0x33,0xda].pack('C*') # l[4]
      dvi_bytes << [0x01,0xd5, 0xc1,0x47].pack('C*') # u[4]
      dvi_bytes << [0x00,0x02].pack('CC') # s[2]
      dvi_bytes << [0x00,0x01].pack('CC') # t[2]
      # p[4], num[4], den[4], mag[4], l[4], u[4], s[2], t[2];

      dvi_bytes << [0xf3].pack('C') # fnt_def1
      # dvi_bytes << "\x00\x4b\xf1\x60\x79\x00\x0a\x00\x00\x00\x05\x63\x6d\x72\x31\x30"
      dvi_bytes << [0x00,0x4b,0xf1,0x60, 0x79, 0x00, 0x0a,0x00,0x00,0x00, 0x0a,0x00, 0x00,0x00,0x05,0x63,0x6d,0x72,0x31,0x30].pack('C*')

    end

    def write_post_post(dvi_bytes)
      dvi_bytes << [0xf9].pack('C')
      # q[4], i[1]; 223's
      dvi_bytes << [0x00, 0x00, 0x00].pack('CCC')
      dvi_bytes << [0xa7].pack('C')
      #dvi_bytes << "\xa7"
      dvi_bytes << [0x02].pack('C')
      5.times { dvi_bytes << [223].pack('C') }
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
      outfile = File.new(file, 'w')
      outfile.print(render.flatten.join)
      outfile.close

    end

  end
end
