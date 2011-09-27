World(Cachier::Matchers)

Before('@caching') do
  Cachier.clear
  Rails.cache.clear
end
