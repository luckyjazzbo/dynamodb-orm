# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'mes/dynamo/version'

Gem::Specification.new do |spec|
  spec.name          = 'mes-dynamo'
  spec.version       = Mes::Dynamo::VERSION
  spec.authors       = ['Roman Lupiichuk', 'Oleg Keene']
  spec.email         = ['ol.keene@gmail.com']

  spec.summary       = 'Core classes to interact with DynamoDB'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = %w(app lib)

  spec.licenses = ['MIT']

  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_dependency 'activemodel', '~> 4.2'
  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'rake', '~> 11.1'

  spec.add_development_dependency 'factory_girl', '~> 4.7'
  spec.add_development_dependency 'bundler', '~> 1.10'
end
