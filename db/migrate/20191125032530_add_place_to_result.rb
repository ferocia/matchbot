# frozen_string_literal: true

class AddPlaceToResult < ActiveRecord::Migration[6.0]
  def change
    add_column :results, :place, :integer, null: true
  end
end
