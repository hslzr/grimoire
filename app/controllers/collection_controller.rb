class CollectionController < ApplicationController
  def index
    @collected_cards = Current.user.collected_cards.includes(:card)
  end
end
