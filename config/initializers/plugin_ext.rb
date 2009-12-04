# Ruby Inline Permissions Hackery
ENV['INLINEDIR'] = File.join(RAILS_ROOT, "/tmp/.rubyinline")

# recaptcha credentials
RCC_PUB = ''
RCC_PRIV = ''

GeoIP.database('')

module WillPaginate
  class LinkRenderer
    def page_link(page, text, attributes = {})
      url = { :action => :paginate, :page => page }
      url.merge!(:id => @options[:params][:id]) if @options[:params]
      @template.link_to_remote text, :url => url, :html => attributes
    end
  end
end