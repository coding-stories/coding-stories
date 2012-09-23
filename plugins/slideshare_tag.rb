module Jekyll
  class Slideshare < Liquid::Tag
    @width = 599
    @height = 487

    def initialize(name, id, tokens)
      super
      @id = id
    end

    def render(context)
      %(<iframe src="http://fr.slideshare.net/slideshow/embed_code/#{@id}" width="599" height="487" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC;border-width:1px 1px 0;margin-bottom:5px" allowfullscreen> </iframe>)
    end
  end
end

Liquid::Template.register_tag('slideshare', Jekyll::Slideshare)
