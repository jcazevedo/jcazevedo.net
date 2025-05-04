module Jekyll
  module FootnotePrefixer
    def prepend_footnote_prefix(input, prefix)
      input.gsub(/\[\^([^\]]+)\]/, "[^#{prefix}-\\1]")
           .gsub(/id="fn:([^\"]+)"/, "id=\"fn:#{prefix}-\\1\"")
           .gsub(/href="#fn:([^\"]+)"/, "href=\"#fn:#{prefix}-\\1\"")
           .gsub(/id="fnref:([^\"]+)"/, "id=\"fnref:#{prefix}-\\1\"")
           .gsub(/href="#fnref:([^\"]+)"/, "href=\"#fnref:#{prefix}-\\1\"")
    end
  end
end

Liquid::Template.register_filter(Jekyll::FootnotePrefixer)
