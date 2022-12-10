class Point 
  include ActiveGraph::Node
  id_property :neo_id
  property :name, type: String
  property :latitude, type: String
  property :longitude, type: String

  def _point
    factory = RGeo::Geographic.simple_mercator_factory
    factory.point(longitude, latitude)
  end
end


