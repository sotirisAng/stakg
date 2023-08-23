class CreateFlightFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :flight_files do |t|
      t.string :collection_name
      t.string :files_type

      t.timestamps
    end
  end
end
