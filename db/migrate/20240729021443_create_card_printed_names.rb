class CreateCardPrintedNames < ActiveRecord::Migration[7.1]
  def up
    create_table :card_printed_names, id: :uuid do |t|
      t.string :name
      t.string :lang
      t.references :card_name, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE card_printed_names
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(name, ''))
      ) STORED;
    SQL

    add_index :card_printed_names, %i[name lang], unique: true
  end

  def down
    remove_index :card_printed_names, %i[name lang]
    drop_table :card_printed_names
  end
end
