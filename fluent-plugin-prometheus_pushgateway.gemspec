Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-prometheus_pushgateway"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Yuta Iwama"]
  spec.email         = ["ganmacs@gmail.com"]

  spec.summary       = %q{A fluent plugin for prometheus pushgateway}
  spec.description   = %q{A fluent plugin for prometheus pushgateway}
  spec.homepage      = "https://github.com/fluent/fluent-plugin-prometheus_pushgateway"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "Apache-2.0"

  spec.add_dependency "fluent-plugin-prometheus", ">= 2.0.0", "< 2.1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "test-unit"
end
