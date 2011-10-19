Gem::Specification.new do |s|
  s.name          = 'cachier'
  s.version       = '0.0.1'
  s.platform      = Gem::Platform::RUBY
  s.author        = 'Avi Tzurel'
  s.email         = 'avi@kensodev.com'
  s.summary       = 'Tagging ability for your cache keys, based on Redis'
  s.description   = 'Tag your cache keys smartly, you can expire by tags, count keys per tag and many more. based on Redis'
  s.hompage       = 'https://github.com/KensoDev/cachier'

  s.files         = Dir.glob('lib/**/*.rb')
  s.test_files    = Dir.glob('spec/**/*.rb')
  s.require_path  = '.'

  s.add_development_dependency('rspec')
  s.add_development_dependency('hiredis')
  s.add_development_dependency('redis')
  s.add_development_dependency('redis-namespace')
end