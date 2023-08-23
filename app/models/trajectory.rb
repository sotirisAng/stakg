require "http"
require 'sparql/client'
require "uri"
require "net/http"

class Trajectory
  include ActiveGraph::Node
  id_property :neo_id
  property :name, type: String
  property :label, type: String
  property :uri, type: String

  has_many :out, :raw_positions, type: :hasPart, model_class: :RawPosition
  has_many :out, :recording_positions, type: :hasPart, model_class: :RecordingPosition
  has_many :both, :intersections, type: :intersects, model_class: :Trajectory
  has_many :out, :intersection_points, type: :hasIntersectionPoint, model_class: :Point

  def get_weather_at_start
    raw_positions = self.raw_positions
    start_position = raw_positions.first
    st_point = start_position.point
    st_time = start_position.time
    start = DateTime.strptime(st_time.hasTime)
    start_day = start.strftime('%Y-%m-%d')
    lat = st_point.latitude
    lon = st_point.longitude

    req = "https://archive-api.open-meteo.com/v1/era5?latitude=#{lat}&longitude=#{lon}&start_date=#{start_day}&end_date=#{start_day}&hourly=temperature_2m,surface_pressure,windspeed_10m"
    res = HTTP.get(req)
    weather = res.parse["hourly"]
    i = 0
    diff = 0
    weather["time"].each_with_index do |time, index|
      time = DateTime.strptime(time, "%Y-%m-%dT%H:%M").to_i
      diff = (time - start.to_i).abs  if diff == 0
      if (time - start.to_i).abs < diff
        diff = (time - start.to_i).abs
        i = index
      end
    end

    weather_condition = WeatherCondition.new.tap do |wc|
      wc.reportedPressure = weather["surface_pressure"][i]
      wc.reportedMaxTemperature = weather["temperature_2m"][i]
      wc.windSpeedMax = weather["windspeed_10m"][i]
      wc.label = "WeatherCont#{wc.neo_id}"
      wc.save
      wc.uri = "https://w3id.org/onto4drone#WeatherCont#{wc.neo_id}"
    end

    raw_positions.each do |rp|
      rp.weather_condition = weather_condition
      rp.save
    end

  end

  def create_recording_segments
    counter = 0
    last_rp = nil
    segment_groups = {}
    positions_with_time = self.raw_positions.map do |position|
      { position: position,
        time: Time.parse(position.time.hasTime) }
    end.sort_by! { |pos| pos[:time] }

    positions_with_time.each do |pos|
      if pos[:position].is_a?(RecordingPosition)
        if last_rp.nil?
          last_rp = pos
          segment_groups[counter] = [pos[:position]]
          next
        end
        if pos[:time] - last_rp[:time] > 15.seconds
          counter += 1
          segment_groups[counter] = [pos[:position]]
        else
          segment_groups[counter] << pos[:position]
        end
        last_rp = pos
      else
        if last_rp.nil?
          next
        end
        if pos[:time] - last_rp[:time] < 15.seconds
          segment_groups[counter] << pos[:position]
        end
      end
    end

    segment_groups.each do |key, value|
      RecordingSegment.new.tap do |rs|
        rs.name = "RecordingSegment#{rs.neo_id}"
        rs.label = "RecordingSegment#{rs.neo_id}"
        rs.uri = "https://w3id.org/onto4drone##{rs.neo_id}"
        rs.positions = value
        rs.save
      end
    end
  end

  def enrich_records_from_aegean
    self.recording_positions.each do |rec_position|
      record = rec_position.recording_event.record
      record.get_poi_from_aegean
    end
  end

  def enrich_records_from_osm
    self.recording_positions.each do |rec_position|
      record =  rec_position.recording_event.record
      record.get_poi_from_osm
    end
  end

  def line
    factory = RGeo::Geographic.simple_mercator_factory
    trajectory_points = self.raw_positions.map do |position|
      factory.point(position.point.longitude, position.point.latitude)
    end
    factory.line_string(trajectory_points)
  end

  def is_intersecting_with?(other_trajectory)
    if self.line.intersects?(other_trajectory.line)
      self.intersections << other_trajectory unless self.intersections.include?(other_trajectory)
      other_trajectory.intersections << self unless other_trajectory.intersections.include?(self)
    end
  end


  def self.create_new_from_csv(logfile)
    CsvReaders.add_id_column(logfile.file_path)
    trajectory = Trajectory.create(name: logfile.name)
    query = case logfile.pilot_type
            when "dji"
              CypherQueries.create_trajectory_from_dji_csv
            when "lichi"
              CsvReaders.change_date_format(logfile.file_path)
              CypherQueries.create_trajectory_from_lichi_csv
            end

    ActiveGraph::Base.query(query, name: logfile.name,  url: logfile.file_path )
                            # url:"http://localhost:3000/logfiles/#{logfile.id}/get_file" ) #"file:///#{logfile.file_path}"
    trajectory
  end

  def add_recording_positions_from_csv(flight_file)
    query = CypherQueries.add_recording_positions_from_csv

    ActiveGraph::Base.query(query, trajectory_label: label, url: flight_file.file_path, base_url: Rails.application.routes.url_helpers.root_url )
  end
end
