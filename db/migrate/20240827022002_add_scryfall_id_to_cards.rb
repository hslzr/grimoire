class AddScryfallIdToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :scryfall_id, :virtual, type: :string, as: "raw_data->>'scryfall_id'", null: false, stored: true
    add_index :cards, :scryfall_id, unique: true
  end
end
