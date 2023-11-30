# frozen_string_literal: true

class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  def self.civic_api_to_representative_params(rep_info)
    rep_info.officials.each_with_index.map do |official, index|
      new_representative_from_official(official, office_for_official(rep_info.offices, index))
    end
  end

  def self.new_representative_from_official(official, office)
    rep = Representative.find_or_initialize_by(name: official.name, ocdid: office[:ocdid])
    assign_representative_details(rep, official, office[:title])
    rep.save!
    rep
  end

  def self.assign_representative_details(rep, official, title)
    rep.title = title
    assign_address(rep, official.address)
    rep.party = official.party || ''
    rep.photo_url = official.photo_url || ''
  end

  def self.assign_address(rep, address)
    return unless address

    # Extracting address fields
    line1, city, state, zip = extract_address_fields(address)

    # Assigning to representative
    rep.street = line1
    rep.city = city
    rep.state = state
    rep.zip = zip
  end

  def self.extract_address_fields(address)
    fields = %i[line1 city state zip]
    fields.map { |field| address[0]&.public_send(field) || '' }
  end

  def self.office_for_official(offices, index)
    offices.each_with_object({ title: '', ocdid: '' }) do |office, acc|
      if office.official_indices.include?(index)
        acc[:title] = office.name
        acc[:ocdid] = office.division_id
      end
    end
  end
end
