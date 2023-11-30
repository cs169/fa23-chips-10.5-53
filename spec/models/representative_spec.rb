# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative, type: :model do
  describe '.civic_api_to_representative_params' do
    let(:address) do
      {
        line1: 'street',
        city:  'city',
        state: 'state',
        zip:   'zip'
      }
    end
    let(:jane_doe) { described_class.find_by(name: 'Jane Doe') }
    let(:john_smith) { described_class.find_by(name: 'John Smith') }

    let(:rep_info) do
      OpenStruct.new(
        officials: [
          OpenStruct.new(
            name:      'Jane Doe',
            address:   [OpenStruct.new(address)],
            party:     'Independent',
            photo_url: 'http://example.com/jane_doe.jpg'
          ),
          OpenStruct.new(
            name:      'John Smith',
            address:   [OpenStruct.new(address)],
            party:     'Democrat',
            photo_url: 'http://example.com/john_smith.jpg'
          )
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

    before do
      described_class.civic_api_to_representative_params(rep_info)
    end

    it 'correctly assigns the name' do
      expect(jane_doe.name).to eq('Jane Doe')
      expect(john_smith.name).to eq('John Smith')
    end

    it 'correctly assigns the title' do
      expect(jane_doe.title).to eq('Mayor')
      expect(john_smith.title).to eq('City Council')
    end

    it 'correctly assigns the street' do
      expect(jane_doe.street).to eq('street')
    end

    it 'correctly assigns the city' do
      expect(jane_doe.city).to eq('city')
    end

    it 'correctly assigns the state' do
      expect(jane_doe.state).to eq('state')
    end

    it 'correctly assigns the zip' do
      expect(jane_doe.zip).to eq('zip')
    end

    it 'correctly assigns the party' do
      expect(jane_doe.party).to eq('Independent')
    end

    it 'correctly assigns the photo URL' do
      expect(jane_doe.photo_url).to eq('http://example.com/jane_doe.jpg')
    end
  end
end
