class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards, id: :uuid do |t|
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :cards, :raw_data, using: :gin
  end
end
