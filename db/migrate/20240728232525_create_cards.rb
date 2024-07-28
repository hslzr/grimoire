class CreateCards < ActiveRecord::Migration[7.1]
  def up
    create_table :cards, id: :uuid do |t|
      t.jsonb :raw_data, null: false, default: {}

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE cards
      ADD COLUMN sname text GENERATED ALWAYS AS (raw_data->>'name') STORED;
    SQL

    execute <<-SQL
      ALTER TABLE cards
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(raw_data->>'name', '')), 'A') ||
        setweight(to_tsvector('english', coalesce(raw_data->>'printed_name', '')), 'B')
      ) STORED;
    SQL

    add_index :cards, :searchable, using: :gin
  end
  
  def down
    remove_index :cards, :searchable
    remove_column :cards, :searchable
    remove_column :cards, :sname
    drop_table :cards
  end
end
