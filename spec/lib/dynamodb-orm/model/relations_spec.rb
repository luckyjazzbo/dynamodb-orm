require 'spec_helper'

RSpec.describe DynamodbOrm::Model::Relations do
  include_context(
    'with dynamodb table',
    'rel_main_models',
    attribute_definitions: [{ attribute_name: 'id', attribute_type: 'S' }],
    key_schema: [{ attribute_name: 'id', key_type: 'HASH' }]
  )

  include_context(
    'with dynamodb table',
    'rel_ref_models',
    attribute_definitions: [{ attribute_name: 'id', attribute_type: 'S' }],
    key_schema: [{ attribute_name: 'id', key_type: 'HASH' }]
  )

  describe '.belongs_to' do
    let(:main_id) { 'main-test' }
    let(:ref_id) { 'ref-test' }

    context 'when settings present' do
      before(:all) do
        Object.send(:remove_const, :RelRefModel) if Object.const_defined?('RelRefModel')
        Object.send(:remove_const, :RelMainModel) if Object.const_defined?('RelMainModel')

        class RelRefModel < DynamodbOrm::Model; end
        class RelMainModel < DynamodbOrm::Model
          belongs_to :ref, class_name: 'RelRefModel', foreign_key: :ref_id
        end
      end

      it 'defines a field' do
        expect(RelMainModel.fields).to have_key(:ref_id)
      end

      describe 'relation getters' do
        context 'when the related object present' do
          before do
            RelRefModel.create!(id: ref_id)
            RelMainModel.create!(id: main_id, ref_id: ref_id)
          end

          it 'defines a getter' do
            expect(RelMainModel.new).to respond_to(:ref)
          end

          it 'finds an object' do
            expect(RelMainModel.first.ref.id).to eq(ref_id)
          end

          it 'caches related objects' do
            main = RelMainModel.first
            expect(main.ref).to equal(main.ref)
          end
        end

        context 'when the related object is not present' do
          let(:main_id) { 'main-test' }
          let(:ref_id) { 'ref-test' }

          before do
            RelMainModel.create!(id: main_id)
          end

          it 'returns nil' do
            expect(RelMainModel.first.ref).to be_nil
          end
        end
      end

      describe 'relation setters' do
        let(:main) { RelMainModel.new }
        let(:ref) { RelRefModel.new(id: ref_id) }

        it 'defines a setter' do
          expect(RelMainModel.new).to respond_to(:ref=)
        end

        it 'sets the foreign_key' do
          expect { main.ref = ref }.to change { main.ref_id }.from(nil).to(ref_id)
        end

        it 'sets an object' do
          expect { main.ref = ref }.to change { main.ref }.from(nil)
        end

        it 'sets foreign_key to nil' do
          main.ref = ref
          expect { main.ref = nil }.to change { main.ref_id }.from(ref_id).to(nil)
        end

        it 'sets object to nil' do
          main.ref = ref
          expect { main.ref = nil }.to change { main.ref }.to(nil)
        end

        it 'does not accept objects with invalid class' do
          expect { main.ref = 'wrong object' }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when no settings present' do
      before(:all) do
        Object.send(:remove_const, :RelRefModel) if Object.const_defined?('RelRefModel')
        Object.send(:remove_const, :RelMainModel) if Object.const_defined?('RelMainModel')

        class RelRefModel < DynamodbOrm::Model; end
        class RelMainModel < DynamodbOrm::Model
          belongs_to :rel_ref_model
        end
      end

      it 'defines default field' do
        expect(RelMainModel.fields).to have_key(:rel_ref_model_id)
      end

      it 'uses default class name' do
        main = RelMainModel.new(rel_ref_model_id: ref_id)
        expect(main.rel_ref_model).to be_nil
      end
    end
  end
end
