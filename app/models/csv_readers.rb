require 'csv'
module CsvReaders

  def self.change_date_format(file_path)
    updated_file_path = file_path.gsub('.csv', '_updated.csv')
    CSV.open(updated_file_path, "wb") do |csv_out|
    CSV.foreach(file_path, headers: true) do |row|
      if csv_out.lineno == 0
        csv_out << row.headers
      end
      row['datetime(utc)'] = row['datetime(utc)'].to_datetime.iso8601
      csv_out << row
    end
    end
  end
end