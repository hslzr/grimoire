class CardsController < ApplicationController
  def search
    @cards = Card.search(search_params[:query])
    render partial: 'cards/search_results', locals: { cards: @cards }
  end

  private

  def search_params
    params.permit(:query)
  end
end
