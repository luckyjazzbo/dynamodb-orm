# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'dynamodb-orm/version'

Gem::Specification.new do |spec|
  spec.name          = 'dynamodb-orm'
  spec.version       = DynamodbOrm::VERSION
  spec.authors       = ['Roman Lupiichuk', 'Bohdan Hryshchenko', 'Anton Priadko', 'Oleg Keene']
  spec.email         = ['roman.lupiychuk@gmail.com', 'ol.keene@gmail.com']

  spec.summary       = 'Core classes to interact with DynamoDB'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = %w(app lib)

  spec.licenses = ['MIT']

  spec.add_dependency 'activesupport', '~> 5.0', '>= 5.0.0.1'
  spec.add_dependency 'activemodel', '~> 5.0'
  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'bundler', '~> 1.10'
end
