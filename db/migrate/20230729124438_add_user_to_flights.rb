class AddUserToFlights < ActiveRecord::Migration[7.0]
  def change
    add_reference :flights, :user, foreign_key: true
    User.reset_column_information
    Flight.reset_column_information
    first_user = User.first
    if first_user.present?
      Flight.update_all(user_id: first_user.id)
    end
  end
end
