Class {
	#name : #BaselineOfReStore,
	#superclass : #BaselineOf,
	#category : #BaselineOfReStore
}

{ #category : #baselines }
BaselineOfReStore >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
				self udbcSQLite: spec.
				self p3: spec.
				spec
					package: 'Wolphin';
					package: 'SSW ReStore Base Additions' with: [ spec requires: #('Wolphin') ];
					package: 'SSW ReStore SQL Entities' with: [ spec requires: #('SSW ReStore Base Additions') ];
					package: 'SSW ReStore SQL Queries' with: [ spec requires: #('SSW ReStore SQL Entities') ];
					package: 'SSW ReStore Tables' with: [ spec requires: #('SSW ReStore SQL Queries') ];
					package: 'SSW ReStore Collections' with: [ spec requires: #('SSW ReStore Tables') ];
					package: 'SSW ReStore Querying' with: [ spec requires: #('SSW ReStore Collections') ];
					package: 'SSW ReStore Main' with: [ spec requires: #('SSW ReStore Querying') ];
					package: 'SSW ReStore for Pharo' with: [ spec requires: #('SSW ReStore Main') ];
					package: 'SSW ReStore UDBC SQLite' with: [ spec requires: #('SSW ReStore for Pharo') ];
					package: 'SSW ReStore Tests' with: [ spec requires: #('SSW ReStore UDBC SQLite') ];
					package: 'SSW ReStore Tests-Pharo' with: [ spec requires: #('SSW ReStore Tests') ];
					package: 'SSW ReStore P3' with: [ spec requires: #('SSW ReStore for Pharo') ] .
				
				spec
					group: 'Tests' with: #(#'SSW ReStore Tests-Pharo');
					group: 'UDBC SQLite' with: #(#'SSW ReStore UDBC SQLite');
					group: 'P3 PostgreSQL' with: #(#'SSW ReStore P3');
					group: 'all' with: #('Tests' 'P3 PostgreSQL');
					group: 'default' with: #('Tests')]
]

{ #category : #baselines }
BaselineOfReStore >> p3: spec [

	spec
		baseline: 'P3'
		with: [
			spec  
				repository: 'github://svenvc/P3'
		]
]

{ #category : #baselines }
BaselineOfReStore >> udbcSQLite: spec [

	spec
		baseline: 'UDBC'
		with: [
			spec  
				loads: #('SQLite');
				repository: 'github://astares/Pharo-UDBC/src'
		]
]
