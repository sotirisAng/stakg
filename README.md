# README
Semantic Trajectories as Knowledge Graphs - STaKG - management application aims to provide a set of methods-scripts to efficiently manage enrich and retrieve data and information related to semantic trajectories. 

The use case that STaKG application is build on, is the management and retrieval of UAV Drone trajectories.
The application is based on Ruby on Rails and utilizes neo4j-ruby-driver and activegraph gems from [Neo4j.rb project](http://neo4jrb.io/) to handle movement logs and record data, stored in Neo4j as Knowledge Graphs.

The  STaKG KG and applications for building and exploiting it are developed following the CHEKG methodology. Phases and tasks of CHEKG are described in the following figures:

![CKEKG phases.png](assets%2FCKEKG%20phases.png)
![CHEKG tasks.png](assets%2FCHEKG%20tasks.png)

The project is currently in progress, management and enrichment methods are placed in model classes which are created based on the [Onto4Drone](https://anonymous.4open.science/r/onto4drone-D556) ontology.
