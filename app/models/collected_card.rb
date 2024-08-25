class CollectedCard < ApplicationRecord
  belongs_to :user
  belongs_to :card

  delegate *%i[
    name
    printed_name
    set
    set_name
    lang
    colors
    mana_cost
    cmc
  ], to: :card
end
