require 'spec_helper'

describe 'DviTools::DviRenderer' do
  describe 'render' do
    doc = DviTools::DviDoc.new
    doc.add_page('Some Text')
    doc.add_page('More Text')
    DviTools::DviRenderer.new.write(doc, '/tmp/gggg.dvi')
  end
end
