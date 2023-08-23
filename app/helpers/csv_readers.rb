require 'csv'
module CsvReaders

  def self.change_date_format(file_path)
    tmp = Tempfile.new

    CSV.open(tmp.path, "wb") do |csv_out|
      CSV.foreach(file_path, headers: true) do |row|
        if csv_out.lineno == 0
          csv_out << row.headers
        end
        row['datetime(utc)'] = row['datetime(utc)'].to_datetime.iso8601
        csv_out << row
      end
    end

    FileUtils.mv(tmp.path, file_path)
  end

  def self.add_id_column(file_path, delimiter = ',')
    tmp = Tempfile.new

    CSV.open(tmp.path, "wb") do |csv_out|
      CSV.foreach(file_path, headers: true, col_sep: delimiter) do |row|
        return if row.headers.include?('id')

        if csv_out.lineno == 0
          csv_out << ['id'] + row.headers
        end
        csv_out << [csv_out.lineno] + row.to_h.values
      end
    end

    FileUtils.mv(tmp.path, file_path)
  end

end