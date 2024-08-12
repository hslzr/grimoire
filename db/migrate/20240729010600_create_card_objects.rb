class CreateCardObjects < ActiveRecord::Migration[7.1]
  def change
    create_table :card_objects, id: :uuid do |t|
      t.jsonb :raw_data
      t.references :card_name, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
