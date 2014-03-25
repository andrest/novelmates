Novelmates::App.controller do

	# before do
	#   ap session[:current_cities] # unless request.env["current_cities"].nil?
	# end

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

	get '/get_book/:isbn' do
	  content_type 'application/json'
	  MultiJson.encode(BookController.get_book(params[:isbn]))
	end



	post '/book/interest' do
	  # params[:interest]
	  # params[:isbn]
	  # ap Interest.where({isbn: params[:isbn], category: params[:interest] }).all.entries
	  i = Interest.where({isbn: params[:isbn], category: params[:interest] })
	  if i.count == 0
	  	i = Interest.create({isbn: params[:isbn], category: params[:interest] })
	  	ap 'new interest' if dev?
	 	end

	  current_user.interests.push(i)
	  # ap current_user
	end

	delete '/book/interest' do
	  # params[:interest]
	  # params[:isbn]
	  # ap Interest.where({isbn: params[:isbn], category: params[:interest] }).all.entries
	  i = Interest.where({isbn: params[:isbn], category: params[:interest], user_ids: current_user._id }).pull(:user_ids, current_user._id)
	  # ap i
	  # ap current_user
	end

end

module BookController
	def self.get_books(query, sort: "relevancerank", page: 1, response_group: "Medium", isbn: '')
		xml = request_books(query, sort, page, response_group, isbn)
		parse_xml_to_books(xml)
	end

	def self.get_book(isbn)
		get_books('', isbn: isbn).first
	end

	def self.lookup_books(isbns)
		ap isbns.join(',')
		get_books('', isbn: isbns.join(','))
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
				"Power"            => "language:english and not(spanish or italian or french or hebrew) and title: not(books OR kit OR box OR set OR trilogy OR 1- OR collector*) and " + query + "* and binding:-kindle -audio",
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

	def self.generate_mosaic(books)
		
		html = "<div class='gallery center'>" 
		books.each do |book|
			interests = Interest.where(isbn: book.isbn).only(:user_ids).distinct(:user_ids)
			meetups = Meetup.where(books: book.isbn).only(:user_ids).distinct(:user_ids)
			people = (interests+meetups).uniq.count
			html += 
			<<-HTML
			<a class="book-link" href="/meetups/for/#{book.isbn}/#{book.get_url_title}">
				<div class="cover-container">
					<div class="cover effect2">
						<div class="front">
							<img src="#{book.images[:large]}" style="max-width:250px;"/>
						</div>
						<div class="back">
							<div class="back-wrap">
								<span class="title"  style="display:block;"><h4>#{book.title}</h4></span>
								<span class="author" style="display:block;">#{book.author}</span>
								<span class="info" style="display:block;">#{people}</span>
								<span class="text" style="display:block;">interested readers</span>
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
		html = [] # "<div id='books'>"
		books.each do |book|
			content = <<-HTML
			<li>
				<a class="book-link" href="/meetups/for/#{book.isbn}/#{book.get_url_title}">
					<div class="cover-wrapper">
						<span class="helper"></span>
						<img class="book-cover hidden" src="#{book.images[:medium]}" >
					</div>
					<div class="book-description">
						<span class="book-title">#{book.title}</span>
						Author: <span> #{book.author}</span>
						ISBN: <span>#{book.isbn}</span>
					</div>
				</a>
			</li>
			HTML
			html.push({id: book.isbn, title: book.title, html_content: content.gsub(/(\t|\n)+/, "")})
		end
		# html += "</div>"

		MultiJson.encode(html)
	end

	def self.look_up(isbn)
		get_book(isbn: isbn)
	end
end