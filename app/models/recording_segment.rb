class RecordingSegment
  include ActiveGraph::Node
  id_property :neo_id
  property :name, type: String
  property :label, type: String
  property :uri, type: String

  has_many :out, :positions, type: :comprises, model_class: :RawPosition

end
