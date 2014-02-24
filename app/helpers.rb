require 'sinatra/base'

module Sinatra
	module AssetTags
		def set_css(file)
			"<link href='http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/css/#{file}.css' rel='stylesheet'>"
		end
		
		def set_js(file)
			"<script src='http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/js/#{file}.js'></script>"
		end
	end
	
	helpers AssetTags
end