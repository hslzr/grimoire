class Card < ApplicationRecord
  ACCESSIBLE_ATTRIBUTES = %i[name printed_name set set_name lang colors mana_cost cmc]

  ## Callbacks
  before_create :set_uuid_v7

  ## Store
  store_accessor :raw_data, *ACCESSIBLE_ATTRIBUTES

  ## Scopes
  # Returns a hash, where the keys are the names of the cards and the values are the cards themselves.
  def self.search(query)
    where("raw_data->>'name' ILIKE :query OR raw_data->>'printed_name' ILIKE :query", query: "%#{query}%")
      .group_by(&:name)
  end

  private

  def set_uuid_v7
    self.id = SecureRandom.uuid_v7
  end
end
