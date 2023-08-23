# frozen_string_literal: true
module CypherQueries

  def self.create_trajectory_from_dji_csv
    <<-CYPHER
    match (c:Class {name:"Trajectory"})
    merge (tr:Trajectory {name: $name})
    merge (tr)-[:rdf__type]->(c)
    set tr.label = 'Traj'+ id(tr), tr.uri = "https://w3id.org/onto4drone#"+'Traj'+ id(tr)
    WITH tr
    CALL apoc.load.csv($url, {header:true}) YIELD map
    AS line
    WITH line, tr
    where toInteger(line.id)%30 = 0
    create (rp:RawPosition)
    set rp.name ='RawP'+ id(rp), rp.label = 'RawP'+ id(rp), rp.uri = "https://w3id.org/onto4drone#"+'RawP'+ id(rp), rp.speed = line["speed"]
    create (tr)-[hp:hasPart]->(rp)
    CREATE (p:Point {location:point({longitude:toFloat(line["GPS:Long"]), latitude:toFloat(line["GPS:Lat"])}), longitude:line["GPS:Long"], latitude:line["GPS:Lat"]})
    set p.label = 'Point'+ id(p), p.name = 'Point'+ id(p), p.uri = "https://w3id.org/onto4drone#"+'point'+ id(p)
    create (t:Time {hasTime:line["GPS:dateTimeStamp"]})
    set t.label = 't'+ id(t), t.name = 't'+ id(t), t.uri = "https://w3id.org/onto4drone#"+'t'+ id(t)
    create (rp)-[hg:hasGeometry]->(p)
    create (rp)-[ht:hasTemporalFeature]->(t)
    return tr
    CYPHER
  end

  def self.create_trajectory_from_lichi_csv
    <<-CYPHER
    match (c:Class {name:"Trajectory"})
    merge (tr:Trajectory {name: $name})
    merge (tr)-[:rdf__type]->(c)
    set tr.label = 'Traj'+ id(tr), tr.uri = "https://w3id.org/onto4drone#"+'Traj'+ id(tr)
    WITH tr
    CALL apoc.load.csv($url, {header:true}) YIELD map
    AS line
    WITH line, tr
    where toInteger(line.id)%30 = 0
    create (rp:RawPosition)
    set rp.name ='RawP'+ id(rp), rp.label = 'RawP'+ id(rp), rp.uri = "https://w3id.org/onto4drone#"+'RawP'+ id(rp), rp.speed = line["speed(mps)"]
    create (tr)-[hp:hasPart]->(rp)
    CREATE (p:Point {location:point({longitude:toFloat(line["longitude"]), latitude:toFloat(line["latitude"])}), longitude:line["longitude"], latitude:line["latitude"]})
    set p.label = 'Point'+ id(p), p.name = 'Point'+ id(p), p.uri = "https://w3id.org/onto4drone#"+'point'+ id(p)
    create (t:Time {hasTime:line["datetime(utc)"]})
    set t.label = 't'+ id(t), t.name = 't'+ id(t), t.uri = "https://w3id.org/onto4drone#"+'t'+ id(t)
    create (rp)-[hg:hasGeometry]->(p)
    create (rp)-[ht:hasTemporalFeature]->(t)
    return tr
    CYPHER
  end

  def self.add_recording_positions_from_csv
    <<-CYPHER
    CALL apoc.load.csv($url, {header:true}) YIELD map
    AS line
    WITH line
    CALL {
        with line
        match (tr:Trajectory {label: $trajectory_label})-[:hasPart]-(rp:RawPosition) 
        match (p2:Point)<-[:hasGeometry]-(rp)
        match (rp)-[:hasTemporalFeature]->(t2)
    with rp, p2, point.distance(point({longitude:toFloat(line["longitude"]), latitude:toFloat(line["latitude"])}), p2.location) as distance, duration.inSeconds(dateTime(line["t"]), datetime(t2.hasTime)) as timeDif
    return rp
    order by distance, timeDif  asc limit 1 }
    set rp:RecordingPosition
    set rp.name ='RecP'+ id(rp), rp.label = 'RecP'+ id(rp)
    create (re:RecordingEvent)
    set re.name ='RecEv'+ id(re), re.label = 'RecEv'+ id(re), re.uri = "https://w3id.org/onto4drone#"+'RecEv'+ id(re)
    create (re)-[:occurs]->(rp)
    create (record:Record {label:line.title, name:line.title})
    set record.uri = "https://w3id.org/onto4drone#record"+ id(record)
set record.file_path = $base_url+ 'records/' + id(record) + '/show'
    create (re)-[:produces]->(record)
    CYPHER
  end
end