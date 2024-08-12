class Card::Name < ApplicationRecord
  scope :search, ->(name) do
    where("searchable @@ websearch_to_tsquery('english', ?)", name)
      .order(Arel.sql("ts_rank(searchable, websearch_to_tsquery('english', ?)) DESC", name))
  end
end
