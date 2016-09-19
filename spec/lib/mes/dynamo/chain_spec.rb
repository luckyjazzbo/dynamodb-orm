require 'spec_helper'

RSpec.describe Mes::Dynamo::Chain do
  include_context(
    'with dynamodb table',
    'movies',
    attribute_definitions: [{
      attribute_name: 'id',
      attribute_type: 'S'
    }, {
      attribute_name: 'title',
      attribute_type: 'S'
    }, {
      attribute_name: 'description',
      attribute_type: 'S'
    }, {
      attribute_name: 'created_at',
      attribute_type: 'N'
    }],
    key_schema: [{
      attribute_name: 'id',
      key_type: 'HASH'
    }],
    global_secondary_indexes: [{
      index_name: 'title_index',
      key_schema: [{
        attribute_name: 'title',
        key_type: 'HASH'
      }],
      projection: {
        projection_type: 'ALL'
      },
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    },{
      index_name: 'description_index',
      key_schema: [{
        attribute_name: 'description',
        key_type: 'HASH'
      }],
      projection: {
        projection_type: 'ALL'
      },
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }, {
      index_name: 'title_created_at_index',
      key_schema: [{
        attribute_name: 'title',
        key_type: 'HASH'
      }, {
        attribute_name: 'created_at',
        key_type: 'RANGE'
      }],
      projection: {
        projection_type: 'ALL'
      },
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }]
  )

  class Movie < Mes::Dynamo::Model
    field :title
    field :description
    field :created_at

    table_index :title, name: 'title_index'
    table_index :description, name: 'description_index'
    table_index :title, range: :created_at, name: 'title_created_at_index'
  end

  let(:avatar_title) { 'Avatar' }
  let(:superman_title) { 'Superman' }

  context 'when scan mode' do
    subject { described_class.new(Movie, scan: true) }

    context '#each' do
      before do
        create_movie(:avatar)
        create_movie(:superman)
      end

      it 'returns all records' do
        expect { |block| subject.each(&block) }.to yield_control.twice
      end

      it 'filters records' do
        expect { |block|
          subject.where(title: avatar_title).each(&block)
        }.to yield_control.once
      end
    end

    context '#limit' do
      before do
        create_movie(:avatar)
        create_movie(:superman)
      end

      it 'limits results' do
        expect { |block| subject.limit(1).each(&block) }.to yield_control.once
      end
    end

    context '#order' do
      it 'raises error' do
        expect { subject.order('desc') }.to raise_error Mes::Dynamo::InvalidQuery
      end
    end

    context '#first' do
      before do
        create_movie(:avatar)
      end

      it 'returns the first object' do
        expect(subject.first.title).to eq avatar_title
      end
    end

    context '#last' do
      it 'raises error' do
        expect { subject.last }.to raise_error Mes::Dynamo::InvalidQuery
      end
    end
  end

  context 'when query mode' do
    let(:chain_with_title_index) do
      subject
        .index('title_index')
        .where(title: avatar_title)
    end

    let(:chain_with_title_created_at_index) do
      subject
        .index('title_created_at_index')
        .where(title: avatar_title)
    end

    subject { described_class.new(Movie) }

    describe '#index' do
      it 'updates query index' do
        expect(subject.index('test').send(:index_name)).to eq 'test'
      end
    end

    describe '#limit' do
      before do
        create_movie(:avatar)
        create_movie(:avatar)
        create_movie(:superman)
      end

      it 'limits results' do
        expect { |block| chain_with_title_index.limit(1).each(&block) }.to yield_control.once
      end
    end

    describe '#filter' do
      before do
        create_movie(:superman)
        create_movie(:superman, description: "I'm Clark Kent")
        create_movie(:avatar)
      end

      let(:base_query) { subject.index('title_index').where(title: 'Superman') }

      context 'when hash passed' do
        let(:query) { base_query.filter(description: "I'm Clark Kent") }

        it 'do not override base query' do
          expect(query.first.title).to eq('Superman')
        end

        it 'filter query properly' do
          expect(query.count).to eq(1)
        end
      end

      context 'when expression and values passed' do
        let(:query) { base_query.filter('description = :description', description: "I'm Clark Kent") }

        it 'do not override base query' do
          expect(query.first.title).to eq('Superman')
        end

        it 'filter query properly' do
          expect(query.count).to eq(1)
        end
      end
    end

    describe '#where' do
      context 'when table is empty' do
        it 'yeilds nothing' do
          expect { |block|
            chain_with_title_index.each(&block)
          }.not_to yield_control
        end
      end

      context 'when there is an item' do
        before do
          create_movie(:avatar)
          create_movie(:superman)
        end

        it 'yeilds all items' do
          expect { |block|
            chain_with_title_index.each(&block)
          }.to yield_control.once
        end

        it 'excepts expression along with values' do
          expect(
            subject
              .index('title_index')
              .where('title = :title', title: avatar_title)
              .to_a
              .size
          ).to eq 1
        end
      end
    end

    describe '#first' do
      context 'when table is empty' do
        it 'returns nil' do
          expect(chain_with_title_index.first).to be nil
        end
      end

      context 'when there is an item' do
        before do
          create_movie(:avatar)
        end

        context 'without where condition' do
          it 'returns last item' do
            expect {
              subject.first.title
            }.to raise_error Mes::Dynamo::InvalidQuery
          end
        end

        context 'with where condition' do
          it 'returns last item' do
            expect(chain_with_title_index.first.title).to eq avatar_title
          end
        end
      end
    end

    describe '#last' do
      context 'when table is empty' do
        it 'returns nil' do
          expect(chain_with_title_index.last).to be nil
        end
      end

      context 'when there is an item' do
        before do
          create_movie(:avatar)
        end

        context 'without where condition' do
          it 'returns last item' do
            expect {
              subject.last.title
            }.to raise_error Mes::Dynamo::InvalidQuery
          end
        end

        context 'with where condition' do
          it 'returns last item' do
            expect(chain_with_title_index.last.title).to eq avatar_title
          end
        end
      end
    end

    context '#order' do
      let!(:movie_1) { create_movie(:avatar, 'created_at' => Time.now.to_i) }
      let!(:movie_2) { create_movie(:avatar, 'created_at' => Time.now.to_i + 1) }

      it 'returns in descending order' do
        expect(
          chain_with_title_created_at_index.order('desc').first.id
        ).to eq(movie_2.id)
      end

      it 'returns in ascending order' do
        expect(
          chain_with_title_created_at_index.order('asc').first.id
        ).to eq(movie_1.id)
      end

      it 'validates orders' do
        expect {
          chain_with_title_created_at_index.order('invalid')
        }.to raise_error ::Mes::Dynamo::InvalidOrder
      end
    end
  end

  private

  def create_movie(name, attrs_overrides = {})
    attrs = {
      'id' => "m-#{rand(999_999)}",
      'created_at' => Time.now.to_i,
      'description' => "I'm Batman."
    }.merge(attrs_overrides)

    case name
    when :avatar
      Movie.create!(
        { 'title' => avatar_title }.merge(attrs)
      )
    when :superman
      Movie.create!(
        { 'title' => superman_title }.merge(attrs)
      )
    end
  end
end
