class PointOfInterest
  include ActiveGraph::Node

  id_property :neo_id
  property :name
  property :name_en
  property :name_de
  property :amenity
  property :label
  property :uri

  has_many :out, :class_nodes, type: :rdf_type, model_class: :ClassNode


end
