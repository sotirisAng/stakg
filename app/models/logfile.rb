class Logfile < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :file

  belongs_to :flight, optional: true, inverse_of: :logfile

  belongs_to :user, inverse_of: :logfiles

  validates :name, presence: true
  validates :pilot_type, presence: true, inclusion: { in: %w[dji lichi] }
  validates :file_type, presence: true
  #validates :file, presence: true

  def file_path
    ActiveStorage::Blob.service.send(:path_for, file.key)
  end

  def url
    url_for(file)
  end

end
