class AddUniqueIndexToGameName < ActiveRecord::Migration[6.0]
  def change
    add_index :games, :name, unique: true
    add_index :games, :emoji_name, unique: true
  end
end
