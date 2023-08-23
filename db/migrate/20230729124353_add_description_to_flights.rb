class AddDescriptionToFlights < ActiveRecord::Migration[7.0]
  def change
    add_column :flights, :description, :text
  end
end
