# frozen_string_literal: true

class CreateAll < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :teams, &:timestamps

    create_table :games do |t|
      t.string :name, null: false
      t.float :default_mean, null: false
      t.float :default_deviation, null: false
      t.string :emoji_name, null: false

      t.timestamps
    end

    create_table :matches do |t|
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end

    create_table :players_teams, id: false do |t|
      t.references :player, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
    end

    create_table :ratings do |t|
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.float :mean, null: false
      t.float :deviation, null: false

      t.timestamps
    end

    create_table :results do |t|
      t.references :match, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.float :score

      t.timestamps
    end

    create_table :rating_events do |t|
      t.references :rating, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.float :mean, null: false
      t.float :deviation, null: false

      t.timestamps
    end
  end
end
