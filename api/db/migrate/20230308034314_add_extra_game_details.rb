class AddExtraGameDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :requires_score, :boolean, null: false, default: false
    add_column :games, :slack_channel_id, :text
    add_column :games, :slack_emoji_url, :text
    add_column :games, :slack_unaliased_name, :text
  end
end
