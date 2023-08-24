class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable #:registerable,

  has_many :flights , dependent: :destroy, inverse_of: :user
  has_many :trajectories, dependent: :destroy, inverse_of: :user
  has_many :logfiles, dependent: :destroy, inverse_of: :user
  has_many :flight_files, dependent: :destroy, inverse_of: :user
end
