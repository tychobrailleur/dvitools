require 'spec_helper'

describe 'DviTools::DviRenderer' do
  describe 'render' do
    DviTools::DviRenderer.new.write('/tmp/gggg.dvi')
  end
end
