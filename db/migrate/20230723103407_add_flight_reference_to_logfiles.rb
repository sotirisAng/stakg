class AddFlightReferenceToLogfiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :logfiles, :flight, foreign_key: true
  end
end
