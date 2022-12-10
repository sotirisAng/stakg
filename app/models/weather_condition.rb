class WeatherCondition
  include ActiveGraph::Node
  id_property :neo_id
  property :reportedMaxTemperature
  property :reportedPressure
  property :description
  property :windSpeedMax
  property :uri

end
