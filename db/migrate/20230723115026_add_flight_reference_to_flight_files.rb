class AddFlightReferenceToFlightFiles < ActiveRecord::Migration[7.0]
  def change
    remove_column :flight_files, :flight_id
    add_reference :flight_files, :flight, foreign_key: true
  end
end
