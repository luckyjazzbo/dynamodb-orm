require 'spec_helper'

RSpec.describe Mes::Dynamo::Model do
  include_context(
    'with dynamodb table',
    'movies',
    attribute_definitions: [{
      attribute_name: 'id',
      attribute_type: 'S'
    }],
    key_schema: [{
      attribute_name: 'id',
      key_type: 'HASH'
    }]
  )

  class Movie < Mes::Dynamo::Model
    field :title,       type: :string
    field :int_field,   type: :integer
    field :float_field, type: :float
    field :complex_field
  end

  let(:id)    { 'v-global' }
  let(:title) { 'The Secret Life of Walter Mitty' }
  let(:movie) { Movie.new }

  describe '#primary_key' do
    class TableWithCustomPrimaryKey < Mes::Dynamo::Model
      table primary_key: 'custom_id'
    end

    it 'saves primary_key' do
      expect(TableWithCustomPrimaryKey.primary_key).to eq('custom_id')
    end
  end

  describe '#attributes' do
    it 'returns empty hash' do
      expect(movie.attributes).to eq({})
    end

    it 'returns updated attributes' do
      movie.title = title
      expect(movie.attributes).to eq('title' => title)
    end
  end

  describe '#read_attribute' do
    before do
      movie.attributes.merge!('title' => title)
    end

    it 'reads attribute' do
      expect(movie.read_attribute(:title)).to eq(title)
    end
  end

  describe '#write_attribute' do
    context 'when attribute is defined' do
      it 'writes an attribute' do
        movie.write_attribute(:title, title)
        expect(movie.title).to eq(title)
      end
    end

    context 'type casting' do
      it 'casts to float' do
        movie.write_attribute(:float_field, '124.25')
        expect(movie.float_field).to eq 124.25
        expect(movie.float_field).to be_kind_of Float
      end

      it 'casts to integer' do
        movie.write_attribute(:int_field, '124.25')
        expect(movie.int_field).to eq 124
        expect(movie.int_field).to be_kind_of Integer
      end

      it 'casts to string' do
        movie.write_attribute(:title, 124.25)
        expect(movie.title).to eq '124.25'
        expect(movie.title.class).to be String
      end

      it 'never stores BigDecimal' do
        movie.write_attribute(
          :complex_field,
          a: BigDecimal.new(123),
          b: [BigDecimal.new(123), BigDecimal.new(123)],
          c: { d: { e: BigDecimal.new(123) } }
        )
        expect(movie.complex_field[:a]).to be_kind_of Float
        expect(movie.complex_field[:b][0]).to be_kind_of Float
        expect(movie.complex_field[:b][1]).to be_kind_of Float
        expect(movie.complex_field[:c][:d][:e]).to be_kind_of Float
      end

      it 'never tries to store empty string' do
        movie.write_attribute(
          :complex_field,
          a: '',
          b: ['', ''],
          c: { d: { e: '' } }
        )
        expect(movie.complex_field[:a]).to be nil
        expect(movie.complex_field[:b][0]).to be nil
        expect(movie.complex_field[:b][1]).to be nil
        expect(movie.complex_field[:c][:d][:e]).to be nil
      end
    end

    context 'when attribute is not defined' do
      it 'does nothing' do
        movie.write_attribute(:does_not_exists, title)
        expect(movie.attributes).to eq({})
      end
    end
  end

  describe 'attribute readers' do
    class ModelWithAttrReaders < Mes::Dynamo::Model
      field :title, type: :string
      field :active, type: :boolean
    end

    subject { ModelWithAttrReaders.new }

    context 'when boolean' do
      it 'responds to both with or without question mark' do
        is_expected.to respond_to(:active)
        is_expected.to respond_to(:active?)
      end
    end

    context 'when not boolean' do
      it 'responds only to the field without question mark' do
        is_expected.to respond_to(:title)
        is_expected.not_to respond_to(:title?)
      end
    end
  end

  describe '#save!' do
    context 'when can be saved' do
      before do
        movie.attributes.merge!(
          'id' => id,
          'title' => title
        )
      end

      it 'saves new object' do
        expect {
          movie.save!
        }.to change { Movie.count }.by(1)
      end
    end

    context 'when cannot be saved' do
      it 'raises exception' do
        expect {
          movie.save!
        }.to raise_error Mes::Dynamo::GenericError
      end
    end
  end

  describe '#save' do
    context 'when can be saved' do
      before do
        movie.attributes.merge!(
          'id' => id,
          'title' => title
        )
      end

      it 'returns true' do
        expect(movie.save).to eq true
      end
    end

    context 'when cannot be saved' do
      it 'returns false' do
        expect(movie.save).to eq false
      end
    end
  end

  describe '#assign_attributes' do
    let(:attributes) { { 'id' => id, 'title' => title } }

    it 'saves new object' do
      movie.assign_attributes(attributes)
      expect(movie.attributes).to eq(attributes)
    end
  end

  describe '#update_attributes!' do
    let(:attributes) { { 'id' => id, 'title' => title } }

    it 'saves new object' do
      movie.update_attributes!(attributes)
      expect(Movie.find(id).attributes).to eq(attributes)
    end
  end

  describe '#update_attributes' do
    let(:attributes) { { 'id' => id, 'title' => title } }

    it 'saves new object' do
      movie.update_attributes(attributes)
      expect(Movie.find(id).attributes).to eq(attributes)
    end
  end

  describe '#delete' do
    let(:movie) do
      Movie.create!(
        id: 'v-delete',
        title: title
      )
    end

    it 'deletes items' do
      movie.delete
      expect(Movie.count).to eq 0
    end
  end

  describe '#<=>' do
    let(:movie_1) { Movie.new(id: 'test') }
    let(:movie_2) { Movie.new(id: 'test') }

    it 'returns -1 for nil' do
      expect(movie_1.<=>(nil)).to eq(-1)
    end

    it 'returns -1 for different type' do
      expect(movie_1.<=>('bla')).to eq(-1)
    end

    it 'returns 0 for a different object with same primary_key' do
      expect(movie_1.<=>(movie_2)).to eq(0)
    end
  end

  describe '.table_name' do
    context 'when is not assigned' do
      it { expect(Movie.table_name).to eq('movies') }
    end

    context 'when is assigned' do
      class FunnyMovie < Mes::Dynamo::Model
        table name: 'custom_table_name'
      end

      it { expect(FunnyMovie.table_name).to eq('custom_table_name') }
    end
  end

  describe '.create!' do
    it 'creates record' do
      expect {
        Movie.create!(
          id: 'v-create!',
          title: title
        )
      }.to change { Movie.count }.by(1)
    end
  end

  describe '.find!' do
    context 'when document exists' do
      before do
        Movie.create!(
          id: id,
          title: title
        )
      end

      it 'feches document by id' do
        result = Movie.find!(id)
        expect(result.title).to eq(title)
      end
    end

    context 'when document does not exist' do
      it 'throws exception' do
        expect {
          Movie.find!('no-such-record')
        }.to raise_error(Mes::Dynamo::RecordNotFound)
      end
    end
  end

  describe '.count' do
    context 'when table does not exist' do
      class ModelWithNoTable < Mes::Dynamo::Model; end

      it 'raise exception' do
        expect {
          ModelWithNoTable.count
        }.to raise_error(Mes::Dynamo::TableDoesNotExist)
      end
    end
  end

  describe '.truncate!' do
    before do
      Movie.create!(
        id: id,
        title: title
      )
    end

    it 'truncates tables' do
      Movie.truncate!
      expect(Movie.count).to eq(0)
    end
  end

  describe '#reload!' do
    context 'with id' do
      let(:new_title) { 'new title' }
      let!(:movie) { Movie.create!(id: id, title: title) }

      before do
        Movie.find(id).update_attributes(title: new_title)
      end

      it 'reloads an object' do
        expect { movie.reload! }.to change { movie.title }.from(title).to(new_title)
      end
    end

    context 'without id' do
      let(:movie) { Movie.new(title: title) }

      it 'raises error' do
        expect { movie.reload! }.to raise_error Mes::Dynamo::InvalidQuery
      end
    end
  end
end
