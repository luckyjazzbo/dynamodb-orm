## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mes-dynamo', git: 'git@github.com:glomex/mes-dynamo.git'
```

## Usage

```ruby
class Movie < ::Mes::Dynamo::Model
  # Optional:
  table name: :sample_table, primary_key: 'custom_id'
  field :title, type: :string

  include ::Mes::Dynamo::Timestamps
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

### Shortcut for MES models:

```ruby
RSpec.describe 'Another cool feature' do
  include_context 'with mes tables'
end
```

## Running tests
```sh
docker-compose up
docker-compose run app rspec
```
