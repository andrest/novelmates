# Shared helpers
Novelmates::App.helpers do
	def set_css(file)
		"<link href='http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/css/#{file}.css' rel='stylesheet'>"
	end
	
	def set_js(file)
		"<script src='http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/js/#{file}.js'></script>"
	end

  def set_js_erb(file)
    "<script src='http://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/js/#{file}.js.erb'></script>"
  end

  def dev?
    ENV['RACK_ENV'] = 'development'
  end
end
