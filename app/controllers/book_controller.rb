Novelmates::App.controller do
	# get '/book/*' do
	#   "Page for book: #{params[:name]}"
	#   params.each do |s|
	#     puts "Parameter: #{s}"
	#   end
	# end
	
	# get '/location/:name' do
	#   "Page for book: #{params[:name]}"
	#   params.each do |s|
	#     puts "Parameter: #{s}"
	#   end
	# end

	# Pattern: /city/isbn/title
	# E.g. /london/97029384567/the-lies-of-lock-lamora
	# get %r{/([\d\+]+)/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
	get %r{/?([\d\s]*)/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
	  # get %r{(?:/)([\d\+])+/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
	  # http://ws.geonames.org/getJSON?formatted=false&geonameId=588335&username=novelmates&style=short
	  city = params[:captures][0].split(' ')
	  isbn = params[:captures][1]

	  @book = BookController.get_book(isbn)
	  
	  @additional_css = stylesheet_link_tag "book"
	  @additional_js  = javascript_include_tag  "book"
	  erb:'books/book'
	end

	get '/get_book/:isbn' do
	  content_type 'application/json'
	  MultiJson.encode(BookController.get_book(params[:isbn]))
	end
end

module BookController
	def self.get_books(query, sort: "salesrank", page: 1, response_group: "Medium", isbn: '')
		xml = request_books(query, sort, page, response_group, isbn)
		parse_xml_to_books(xml)
	end

	def self.get_book(isbn)
		get_books('', isbn: isbn).first
	end

	def self.request_books(query, sort, page, response_group, isbn)
		aUri = URI.parse("http://webservices.amazon.com/onca/xml")
		parameters = { 
			"Service"          => "AWSECommerceService",
			"AWSAccessKeyId"   => ENV['AWS_ACCESS_KEY'],
			"AssociateTag"     => "place",
			"ResponseGroup"    => response_group,
			"SearchIndex"      => "Books",
			"Timestamp"        => AWS.current_time.getutc.iso8601,
			"SignatureVersion" => '2'
		}

		if isbn == ''
			additional_params = {
				"Operation"        => "ItemSearch",
				"Power"            => "language:english and not(spanish or italian or french or hebrew) and title: not(books OR box OR set OR trilogy OR 1- OR collector*) and " + query + "* and binding:-kindle -audio",
				"Sort"             => sort,
				"ItemPage"         => page,
			}
			else
				additional_params = {
				"Operation"        => "ItemLookup",
				"IdType"           => "ISBN",
				"ItemId"           => isbn
			}
		end
		parameters.merge!(additional_params)
		AWS.set_config
		res = AWS.do_query("GET", aUri, parameters)
		doc = Nokogiri::XML(res.body)
		# p res.body
		doc.remove_namespaces!
	end

	def self.parse_xml_to_books(xml_response)
		books = []
		
		xml_response.css("Items Item").each do |item|
			if item.css('ISBN').empty? then next end
			
			book = Book.new
			book.asin 	= item.css('ASIN')                							unless item.css('ASIN').empty?
			book.url 	= item.css('DetailPageURL').text() 			 					unless item.css('DetailPageURL').empty?
			book.author = item.css('Author').to_a.join(', ') 	    	 			unless item.css('Author').empty?
			book.isbn 	= item.css('ISBN').text()     	 					unless item.css('ISBN').empty?
			book.full_title 	= item.css('Title').text()     	 					unless item.css('Title') .empty?
			book.images[:small] = item.at_css('ImageSets SmallImage URL').text() 	unless item.css('ImageSets SmallImage URL').empty?
			book.images[:medium] = item.at_css('ImageSets MediumImage URL').text() 	unless item.css('ImageSets MediumImage URL').empty?
			book.images[:large] = item.at_css('ImageSets LargeImage URL').text() 	unless item.css('ImageSets LargeImage URL').empty?
			book.editorial_review = item.at_css('EditorialReviews EditorialReview Content').text() unless item.css('EditorialReviews EditorialReview Content').empty?
			book.published_at = item.at_css('PublicationDate').text() unless item.css('PublicationDate').empty?

			books.push book
		end	
		books
	end	

	def self.lookup_book(isbn)
		"testing"
	end

	def self.generate_mosaic(books)
		html = "<div class='gallery center'>" 
		books.each do |book|
			html += 
			<<-HTML
			<a class="book-link" href="/#{book.isbn}/#{book.get_url_title}">
				<div class="cover-container">
					<div class="cover">
						<div class="front">
							<img src="#{book.images[:large]}" style="max-width:250px;"/>
						</div>
						<div class="back">
							<div class="back-wrap">
								<span class="title"  style="display:block;"><h4>#{book.title}</h4></span>
								<span class="author" style="display:block;">#{book.author}</span>
								<span class="info" style="display:block;">#{rand(8)+1}</span>
								<span class="text" style="display:block;">interested readers in your area</span>
							</div>
						</div>
					</div>
				</div>
			</a>
			HTML
		end
		html += "</div>"
	end

	# TODO: GeoIP for city
	def self.generate_search_results(books)
		html = '' # "<div id='books'>"
		books.each do |book|
			html +=
			<<-HTML
			<li>
				<a class="book-link" href="/#{book.isbn}/#{book.get_url_title}">
					<div class="cover-wrapper">
						<span class="helper"></span>
						<img class="book-cover hidden" src="#{book.images[:medium]}" >
					</div>
					<div class="book-description">
						<span class="book-title">#{book.title}</span>
						Author: <span class="book-author"> #{book.author}</span>
						ISBN: <p class="isbn">#{book.isbn}</p>
					</div>
				</a>
			</li>
			HTML
		end
		# html += "</div>"
		html
	end

	def self.look_up(isbn)
		get_book(isbn: isbn)
	end
end