# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative, type: :model do
  describe '.civic_api_to_representative_params' do
    let(:rep_info) do
      OpenStruct.new(
        officials: [
          OpenStruct.new(name: 'Jane Doe'),
          OpenStruct.new(name: 'John Smith')
        ],
        offices:   [
          OpenStruct.new(
            name:             'Mayor',
            division_id:      'id0',
            official_indices: [0]
          ),
          OpenStruct.new(
            name:             'City Council',
            division_id:      'id1',
            official_indices: [1]
          )
        ]
      )
    end

    context 'when the representative does not exist' do
      it 'creates a new representative' do
        expect do
          described_class.civic_api_to_representative_params(rep_info)
        end.to change(described_class, :count).by(2)
      end
    end

    context 'when the representative already exists' do
      before do
        described_class.create!(name: 'Jane Doe', ocdid: 'id0', title: 'Mayor')
      end

      it 'does not create a duplicate representative' do
        expect do
          described_class.civic_api_to_representative_params(rep_info)
        end.to change(described_class, :count).by(1)
      end
    end
  end
end
