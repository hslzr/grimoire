class CreateCollectedCards < ActiveRecord::Migration[7.2]
  def change
    create_table :collected_cards, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :card, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
