class TemporalFeature
  include ActiveGraph::Node
  id_property :neo_id
  property :hasTime, type: String

  self.mapped_label_name = 'Time'
end
