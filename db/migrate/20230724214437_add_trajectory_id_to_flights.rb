class AddTrajectoryIdToFlights < ActiveRecord::Migration[7.0]
  def change
    add_column :flights, :trajectory_id, :integer
  end
end
