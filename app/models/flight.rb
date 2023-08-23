class Flight < ApplicationRecord
  has_one :flight_file
  has_one :logfile

  accepts_nested_attributes_for :flight_file
  accepts_nested_attributes_for :logfile

  belongs_to :user, inverse_of: :flights
end
