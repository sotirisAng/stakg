class ClassNode
  include ActiveGraph::Node

  id_property :neo_id
  property :name
  property :label
  property :uri

end
