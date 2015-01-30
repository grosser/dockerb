name = "dockerb"
require "./lib/#{name.gsub("-","/")}/version"

Gem::Specification.new name, Dockerb::VERSION do |s|
  s.summary = "Dockerfile.erb - use ruby in your Dockerfile"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib/ bin/ MIT-LICENSE`.split("\n")
  s.license = "MIT"
  s.executables = ["dockerb"]
end
