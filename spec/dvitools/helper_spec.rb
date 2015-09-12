require 'spec_helper'

describe 'DviTools::Helper' do
  let(:helped_class) { Class.new { include DviTools::Helper } }
  subject { helped_class.new }

  describe 'peek' do
    let(:s) { StringIO.new([65, 66, 67].pack('C*')) }

    it 'returns a byte' do
      subject.peek(s).should eq(65)
    end

    it 'reinserts the read byte' do
      subject.peek(s)
      s.readbyte.should eq(65)
    end
  end

  describe 'four_byte_unsigned' do
    let(:s) { StringIO.new([0x01, 0x83, 0x92, 0xc0].pack('C*')) }

    it 'reads four bytes and converts them to an unsigned integer' do
      d = subject.four_byte_unsigned(s)
      d.should eq(25400000)
    end
  end
end
