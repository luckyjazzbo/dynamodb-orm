# DynamodbOrm (System:MES,Squad:publisher,Type:Component)
[![Build Status](https://travis-ci.org/glomex/dynamodb-orm.svg?branch=master)](https://travis-ci.org/glomex/dynamodb-orm)

A simple abstraction over AWS DynamoDB service.

## Technology
* ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamodb-orm', git: 'git@github.com:glomex/dynamodb-orm.git'
```

## Usage

```ruby
class Movie < DynamodbOrm::Model
  # Optional:
  table name: :sample_table, primary_key: 'custom_id'
  field :title, type: :string

  include DynamodbOrm::Timestamps
  # Adds created_at and updated_at with auto-assigns
end
```

Check specs for examples.

## Spec helpers

Gem provides a helper to create arbitrary DynamoDB table which will be created before the whole test suit and dropped after:

```ruby
RSpec.describe 'A cool feature' do
  include_context(
    'with dynamodb table',
    'arbitrary-table-name',
    attribute_definitions: [{
      attribute_name: 'content_id',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'content_id',
      key_type: 'HASH'
    }]
  )
end
```

## Running tests
```sh
docker-compose run app bundle install
docker-compose run app bundle exec rspec
```
