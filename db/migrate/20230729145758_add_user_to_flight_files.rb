class AddUserToFlightFiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :flight_files, :user, foreign_key: true
    User.reset_column_information
    FlightFile.reset_column_information
    first_user = User.first
    if first_user.present?
      FlightFile.update_all(user_id: first_user.id)
    end
  end
end
