class AddUniqueIndexToCardsId < ActiveRecord::Migration[7.2]
  def change
    add_index :cards, :id, unique: true
  end
end
