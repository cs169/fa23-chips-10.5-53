# frozen_string_literal: true

class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  class << self
    def civic_api_to_representative_params(rep_info)
      rep_info.officials.each_with_index.map do |official, index|
        process_official(official, index, rep_info.offices)
      end
    end

    private

    def process_official(official, index, offices)
      title_temp, ocdid_temp = find_office_details_for_official(index, offices)
      rep = find_or_initialize_rep(official, ocdid_temp)
      assign_rep_attributes(rep, official, title_temp)
      rep.save!
      rep
    end

    def find_office_details_for_official(index, offices)
      offices.each do |office|
        return [office.name, office.division_id] if office.official_indices.include?(index)
      end
      ['', '']
    end

    def find_or_initialize_rep(official, ocdid_temp)
      Representative.find_or_initialize_by(name: official.name, ocdid: ocdid_temp)
    end

    def assign_rep_attributes(rep, official, title)
      # Simplify this method if it's still too complex
      rep.title = title
      address = official.address ? official.address[0] : {}
      rep.street = address&.line1 || ''
      rep.city = address&.city || ''
      rep.state = address&.state || ''
      rep.zip = address&.zip || ''
      rep.party = official.party || ''
      rep.photo_url = official.photo_url || ''
    end
  end
end
