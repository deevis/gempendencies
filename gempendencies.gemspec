lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gempendencies/version"

Gem::Specification.new do |spec|
  spec.name          = "gempendencies"
  spec.version       = Gempendencies::VERSION
  spec.authors       = ["Darren Hicks"]
  spec.email         = ["darren.hicks@gmail.com"]

  spec.summary       = %q{Builds a comprehensive list of gems used by your project and summarizes the OSS Licenses being used}
  spec.description   = %q{Builds a comprehensive list of gems used by your project and summarizes the OSS Licenses being used}
  spec.homepage      = "https://github.com/deevis/gempendencies"
  spec.license       = "MIT"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/deevis/gempendencies"
#  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = ["bin/gempendencies", "README.md"] + Dir["lib/**/*"]
  spec.executables = ["gempendencies"]

  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
