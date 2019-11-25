class MakePlayerNameCaseInsensitive < ActiveRecord::Migration[6.0]
  def change
    enable_extension :citext
    change_column :players, :name, :citext
  end
end
