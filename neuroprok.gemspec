# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neuroprok/version'

Gem::Specification.new do |spec|
  spec.name          = "neuroprok"
  spec.version       = Neuroprok::VERSION
  spec.authors       = ["sheff3rd", "maximsilver"]
  spec.email         = ["thedoctorwhoovesmail@gmail.com"]

  spec.summary       = %q{Neural network for deanonymizing code.}
  spec.description   = %q{Creating webhooks for commits and training the model on ruby files.}
  spec.homepage      = "https://github.com/Sheff3rd/neuroprok.gem"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
