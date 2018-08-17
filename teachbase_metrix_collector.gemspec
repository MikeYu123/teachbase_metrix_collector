
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teachbase_metrix_collector/version"

Gem::Specification.new do |spec|
  spec.name          = "teachbase_metrix_collector"
  spec.version       = Teachbase::MetrixCollector::VERSION
  spec.authors       = ["Yurchenkov Mikhail"]
  spec.email         = ["mikesehse@gmail.com.ru"]

  spec.summary       = %q{short summary} #TODO write short summary here
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-configurable", "~> 0.6.2"
  # spec.add_dependency "dry-rb", "~> 0.6.2"
  spec.add_dependency "rails", "~> 5.1.1"
  spec.add_dependency "activesupport", "~> 5.1.1"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
end
