class AddUserToLogiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :logfiles, :user, foreign_key: true
    User.reset_column_information
    Logfile.reset_column_information
    first_user = User.first
    if first_user.present?
      Logfile.update_all(user_id: first_user.id)
    end
  end
end
