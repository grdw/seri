lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serializer/version'

Gem::Specification.new do |spec|
  spec.name          = 'seri'
  spec.version       = Serializer::VERSION
  spec.authors       = ['grdw']
  spec.email         = ['gerard@wetransfer.com']

  spec.summary       = 'A basic serializer'
  spec.description   = 'A basic serializer'
  spec.homepage      = 'https://github.com/grdw/seri'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'appsignal', '~> 2.7'
  spec.add_dependency 'oj', '~> 3.7'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.67.2'
end
