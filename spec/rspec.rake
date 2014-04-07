task :rspec do |t|
  spec_tasks = Dir['spec/*/'].inject([]) do |result, d|
    result << File.basename(d) unless Dir["#{d}*"].empty?
    result
  end

  tasks = spec_tasks.map{ |folder| Dir["./spec/#{folder}/**/*_spec.rb"] }
  s = 'rspec ' + tasks.flatten.join(' && rspec ')
  puts %x( #{s} )
end
