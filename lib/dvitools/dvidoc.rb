module DviTools
  class DviDoc
    attr_accessor :num, :den, :mag, :comment, :pages

    def initialize
      @num = 25400000
      @den = 473628672
      @mag = 1000
      @comment = 'DviTools'
      @pages = []
    end

    def add_page(content)
      @pages << content
    end
  end
end
