class RdfResource
  include ActiveGraph::Node

  def self.find(label)
    ActiveGraph::Base.query("MATCH (n) WHERE n.label = '#{label}' RETURN n").first
  end
end
