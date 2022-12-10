class RawPosition
  include ActiveGraph::Node

  id_property :neo_id
  property :name
  property :label
  property :uri

  has_one :out, :time, type: :hasTemporalFeature, model_class: :TemporalFeature
  has_one :out, :point, type: :hasGeometry, model_class: :Point
  has_one :out, :weather_condition, type: :hasWeatherCondition, model_class: :WeatherCondition
  has_one :in, :trajectory, type: :hasPart, model_class: :Trajectory
  has_one :in, :recording_segment, type: :comprises, model_class: :RecordingSegment

end
