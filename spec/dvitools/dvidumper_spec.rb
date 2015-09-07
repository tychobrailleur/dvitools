require 'spec_helper'


describe 'DviDumper' do
  it 'loads a DVI file' do
    DviTools::DviDumper.new.dump('./resources/example.dvi')
  end

  it 'loads a DVI file with two pages' do
    DviTools::DviDumper.new.dump('./resources/example2.dvi')
  end

  it 'loads a DVI file with different font size' do
    DviTools::DviDumper.new.dump('./resources/example3.dvi')
  end
end
