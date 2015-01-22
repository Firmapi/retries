lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "retries/version"

Gem::Specification.new do |gem|
  gem.name          = "retries"
  gem.version       = Retries::VERSION
  gem.authors       = ["Antoine Finkelstein"]
  gem.email         = ["antoine@firmapi.com"]
  gem.description   = %q{Retries is a gem for retrying blocks with randomized exponential backoff.}
  gem.summary       = %q{Retries is a gem for retrying blocks with randomized exponential backoff.}
  gem.homepage      = "https://github.com/firmapi/retries"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # For running the tests
  gem.add_development_dependency "minitest", "~> 5.0"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rr", "~> 1.1"
  gem.add_development_dependency "coveralls"
end
