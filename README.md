# README
Semantic Trajectories as Knowledge Graphs - STaKG - management application aims to provide a set of methods-scripts to efficiently manage enrich and retrieve data and information related to semantic trajectories. 

The use case that STaKG application is build on, is the management and retrieval of UAV Drone trajectories.
The application is based on Ruby on Rails and utilizes neo4j-ruby-driver and activegraph gems from [Neo4j.rb project](http://neo4jrb.io/) to handle movement logs and record data, stored in Neo4j as Knowledge Graphs.

The project is currently in progress, management and enrichment methods are placed in model classes which are created following the [Onto4Drone](https://github.com/KotisK/onto4drone) ontology.
