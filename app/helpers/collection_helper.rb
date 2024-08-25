module CollectionHelper
  def display_name_for(card)
    if card.printed_name.present?
      return "#{card.name} (#{card.printed_name})"
    end

    card.printed_name.presence || card.name
  end
end
