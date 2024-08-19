require_relative 'lib/flip/version'

Gem::Specification.new do |spec|
  spec.name          = "flip"
  spec.version       = Flip::VERSION
  spec.authors       = ["ardianys"]
  spec.email         = ["ardianys@gmail.com"]

  spec.summary       = "Flip Payment Gateway"
  spec.description   = "Flip Payment Gateway"
  spec.homepage      = "https://ardianys.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = "https://ardianys.com"
  spec.metadata["source_code_uri"] = "https://ardianys.com"
  spec.metadata["changelog_uri"] = "https://ardianys.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
