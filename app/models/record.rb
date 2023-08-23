require "http"
require 'sparql/client'
require "uri"
require "net/http"

class Record
  include ActiveGraph::Node
  id_property :neo_id
  property :name
  property :label
  property :file_path

  has_many :out, :pois, type: :records, model_class: :PointOfInterest
  has_one :in, :recording_event, type: :produces, model_class: :RecordingEvent

  def get_poi_from_aegean #(lat = 26.5694234, lon = 39.0850815)
    lat = self.recording_event.recording_position.point.latitude
    lon = self.recording_event.recording_position.point.longitude

    query = %{PREFIX geo: <http://www.opengis.net/ont/geosparql#>
              PREFIX geof: <http://www.opengis.net/def/function/geosparql/>
              PREFIX uoa: <http://semantics.aegean.gr/ontology/>
              Prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX units: <http://www.opengis.net/def/uom/OGC/1.0/>
              SELECT ?entity ?class ?label ?eLabel
              WHERE {
                ?entity a ?class.
              OPTIONAL{?entity uoa:hasLabel ?eLabel.}
                ?class rdfs:label ?label.
              ?entity geo:hasGeometry ?geo .
              ?geo geo:asWKT ?wkt .
                bind (geof:distance("<http://www.opengis.net/def/crs/EPSG/0/4326>POINT (#{lon} #{lat})"^^geo:wktLiteral, ?wkt, units:degree) as ?d)
              FILTER (?d < 0.0005)
                FILTER contains(str(?wkt),"POINT")
              } LIMIT 100
            }.gsub(/\s+/, "+").gsub(/#/, "%23").strip

    url = URI("http://semantics.aegean.gr:3030/data?query=" + query)

    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = ENV["AEGEAN_AUTH"]

    response = JSON.parse(http.request(request).read_body)

    aegean_results = response["results"]["bindings"].select do |bind|
      bind["class"]["value"].include?("http://semantics.aegean.gr/ontology")
    end

    aegean_results.each do |result|
      unless (entity_class = ClassNode.find_by(uri: result["class"]["value"]))
        entity_class = ClassNode.new.tap do |klass|
          klass.label = result["label"]["value"]
          klass.name = result["label"]["value"]
          klass.uri = result["class"]["value"]
          klass.save
        end
      end

      unless (entity = PointOfInterest.find_by(uri: result["entity"]["value"]))
        entity = PointOfInterest.new.tap do |entity|
          entity.uri = result["entity"]["value"]
          entity.label = result["eLabel"]["value"] if result["eLabel"] && result["eLabel"]["value"]
          entity.class_nodes << entity_class
          entity.save
        end
      end
      self.pois << entity unless self.pois.include?(entity)
    end
  end

  def get_poi_from_osm
    sleep 5
    lat = self.recording_event.recording_position.point.latitude
    lon = self.recording_event.recording_position.point.longitude

    url = URI("http://overpass-api.de/api/interpreter?data=[out:json];
              node(around:50,#{lat},#{lon})-> .sn;
              node.sn[name];
              out geom;")

    begin
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)

      response = JSON.parse(http.request(request).read_body)
    rescue => e
      @attempts += 1
      if @attempts < 3
        puts "Timeout error, retrying #{e}..."
        retry
      end
      puts "Timeout error, giving up #{e}..."
      return
    end

    response["elements"].each do |element|
      case element["type"]
      when "node"
        uri = "https://www.openstreetmap.org/node/#{element["id"]}"
      when "way"
        uri = "https://www.openstreetmap.org/way/#{element["id"]}"
      end

      unless (entity = PointOfInterest.find_by(uri: uri))
        entity = PointOfInterest.new.tap do |entity|
          entity.uri = uri
          entity.name = element["tags"]["name"] if element["tags"]["name"]
          entity.name_en = element["tags"]["name:en"] if element["tags"]["name:en"]
          entity.name_de = element["tags"]["name:de"] if element["tags"]["name:de"]
          entity.amenity = element["tags"]["amenity"] if element["tags"]["amenity"]
          entity.save
        end
      end

      self.pois << entity unless self.pois.include?(entity)
    end
  end
end
