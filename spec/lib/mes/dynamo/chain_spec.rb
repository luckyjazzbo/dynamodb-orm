require 'spec_helper'

RSpec.describe Mes::Dynamo::Chain do
  include_context(
    'with dynamodb table',
    :movies,
    attribute_definitions: [{
      attribute_name: 'content_id',
      attribute_type: 'S'
    }, {
      attribute_name: 'title',
      attribute_type: 'S'
    }, {
      attribute_name: 'created_at',
      attribute_type: 'N'
    }],
    key_schema: [{
      attribute_name: 'content_id',
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
    field :created_at
  end

  let(:avatar_title) { 'Avatar' }
  let(:superman_title) { 'Superman' }

  context 'when scaning' do
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
      subject do
        described_class.new(Movie)
          .index('title_created_at_index')
          .where(title: avatar_title)
      end

      let!(:movie_1) { create_movie(:avatar, 'created_at' => Time.now.to_i) }
      let!(:movie_2) { create_movie(:avatar, 'created_at' => Time.now.to_i + 1) }

      it 'raises error in scan mode' do
        expect { described_class.new(Movie, scan: true).last }.to raise_error Mes::Dynamo::InvalidQuery
      end

      it 'returns in reverse order' do
        expect(subject.order('desc').first.content_id).to eq movie_2.content_id
      end

      it 'returns in ascending order' do
        expect(subject.order('asc').first.content_id).to eq movie_1.content_id
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

  context 'when querying' do
    let(:chain_with_where) do
      subject
        .index('title_index')
        .where(title: avatar_title)
    end

    subject { described_class.new(Movie) }

    describe '#index' do
      it 'updates query index' do
        expect(subject.index('test').index_name).to eq 'test'
      end
    end

    describe '#limit' do
      before do
        create_movie(:avatar)
        create_movie(:avatar)
        create_movie(:superman)
      end

      it 'limits results' do
        expect { |block| chain_with_where.limit(1).each(&block) }.to yield_control.once
      end
    end

    describe '#where' do
      context 'when table is empty' do
        it 'yeilds nothing' do
          expect { |block|
            chain_with_where.each(&block)
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
            chain_with_where.each(&block)
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
          expect(chain_with_where.first).to be nil
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
            expect(chain_with_where.first.title).to eq avatar_title
          end
        end
      end
    end

    describe '#last' do
      context 'when table is empty' do
        it 'returns nil' do
          expect(chain_with_where.last).to be nil
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
            expect(chain_with_where.last.title).to eq avatar_title
          end
        end
      end
    end
  end

  private

  def create_movie(name, attrs_overrides = {})
    attrs = {
      'content_id' => "m-#{rand(999_999)}",
      'created_at' => Time.now.to_i
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
