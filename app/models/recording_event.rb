class RecordingEvent
  include ActiveGraph::Node
  id_property :neo_id

  property :name
  property :label
  property :uri

  has_one :out, :record, type: :produces, model_class: :Record
  has_one :out, :recording_position, type: :occurs, model_class: :RecordingPosition


end
