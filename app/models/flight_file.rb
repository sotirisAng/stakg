require 'csv'
require 'exifr/jpeg'

class FlightFile < ApplicationRecord
  has_many_attached :files
  has_one_attached :csv_file

  belongs_to :flight, optional: true, inverse_of: :flight_file

  belongs_to :user, inverse_of: :flight_files
  def file_thumbnail(file)
    return file unless file.content_type.in?(%w(image/jpeg image/png image/gif))
    file.variant(resize_to_limit: [300, 300]).processed
  end

  def self.file_path(file)
    ActiveStorage::Blob.service.send(:path_for, file.key)
  end

  def file_path
    ActiveStorage::Blob.service.send(:path_for, csv_file.key)
  end

  def create_csv_from_files
    # Create a CSV file from the attached files
    CSV.open(["tmp","#{collection_name}.csv"].join("/"), "w") do |csv|
      headers = %w[id latitude longitude altitude title time camera_model path]
      if csv.lineno == 0
        csv << headers
      end
      files.each do |file|
        image = EXIFR::JPEG.new(FlightFile.file_path(file))
        lat = image.gps.latitude
        long = image.gps.longitude
        alt = image.gps.altitude
        title = file.filename.to_s
        time = image.date_time.to_s.to_datetime.utc.iso8601
        model = image.model
        path = FlightFile.file_path(file)
        # puts lat, long, alt, title, time, model

        csv << CSV::Row.new(headers,[csv.lineno, lat, long, alt, title, time, model, path])
      end
    end

    csv_file.attach(io: File.open(["tmp","#{collection_name}.csv"].join("/")), filename: "#{collection_name}.csv", content_type: 'text/csv')
    save

  end
end
