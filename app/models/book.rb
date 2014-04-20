class Book
  attr_accessor :asin 
  attr_accessor :author
  attr_accessor :isbn
  attr_accessor :title
  attr_accessor :sub_title
  attr_reader	:full_title
  attr_accessor :images
  attr_accessor :url
  attr_accessor :editorial_review
  attr_accessor :published_at

	def initialize()
		@images = {}
	end
	def full_title=(full_title)
    	match = full_title.match(/(.+):(.+)/)
    	if match.nil?
    		@title = full_title
    		@sub_title = ''
    	else
	    	@title = match[1]
	    	@sub_title = match[2]
	    end
	    @full_title = full_title
  	end
	def get_url_title()
		url_title = title.downcase
		junk = [ "and", "or", "the", "a", "an", "of", "to" ]
		# junk.map! { |x| "(\A|\s+)#{x}(\z|\s+)" }
		# junk.each do |word|
		# 	url_title.gsub!(Regexp.new(word), ' ')
		# end
		url_title.gsub!(/\W/, ' ')
		url_title.strip!
		url_title.gsub!(/\s/, '-')
		url_title.gsub!(/-+/, '-')
 		url_title
	end
end