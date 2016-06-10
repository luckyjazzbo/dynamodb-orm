## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mes-dynamo', git: 'git@github.com:glomex/mes-dynamo.git', require: 'mes/dynamo'
```

## Usage

```ruby
class Movie
  include Mes::Dynamo::Model

  # Optional:
  table name: :sample_table, primary_key: 'custom_id'
  field :title

  include Mes::Dynamo::Timestamps
  # To get for free with auto-assigns
  # field :created_at
  # field :updated_at
end
```

Check specs for examples.

## Specs

Gem provides helper to create DynamoDB table which will be dropped after specs:
```ruby
RSpec.describe Movie do
  include_context 'with dynamodb table',
    Movie.table_name,
    attribute_definitions: [{
      attribute_name: 'content_id',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'content_id',
      key_type: 'HASH'
    }]
end
```

**Shortcuts for exists tables:**

 - include_context 'with original_resources'
 - include_context 'with transformation_steps'
 - include_context 'with transformed_resources'
