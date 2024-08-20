class Card < ApplicationRecord

  ACCESSIBLE_ATTRIBUTES = %i[name printed_name set lang colors mana_cost cmc]

  store_accessor :raw_data, *ACCESSIBLE_ATTRIBUTES

  # Returns a hash, where the keys are the names of the cards and the values are the cards themselves.
  def self.search(query)
    where("raw_data->>'name' ILIKE :query OR raw_data->>'printed_name' ILIKE :query", query: "%#{query}%")
      .group_by(&:name)
  end
end
