class CreateCardNames < ActiveRecord::Migration[7.1]
  def up
    create_table :card_names, id: :uuid do |t|
      t.string :name
      t.string :lang

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE card_names
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(name, ''))
      ) STORED;
    SQL

    add_index :card_names, :searchable, using: :gin
    add_index :card_names, %i[name lang], unique: true
  end

  def down
    remove_index :card_names, :searchable
    remove_column :card_names, :searchable
    remove_column :card_names, :sname
    drop_table :card_names
  end
end
