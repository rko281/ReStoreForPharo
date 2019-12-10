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
				self sqlite3: spec.
				self p3: spec.
				self udbcSQLite: spec.
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
					package: 'SSW ReStore SQLite3' with: [ spec requires: #('SSW ReStore for Pharo' 'Pharo-SQLite3') ];
					package: 'SSW ReStore Tests' with: [ spec requires: #('SSW ReStore SQLite3') ];
					package: 'SSW ReStore Tests-Pharo' with: [ spec requires: #('SSW ReStore Tests') ];
					package: 'SSW ReStore Examples' with: [ spec requires: #('SSW ReStore SQLite3') ];
					package: 'SSW ReStore P3' with: [ spec requires: #('SSW ReStore for Pharo' 'P3') ];
					package: 'SSW ReStore UDBC SQLite' with: [ spec requires: #('SSW ReStore for Pharo' 'UDBC') ] .
				
				spec
					group: 'Tests' with: #(#'SSW ReStore Tests-Pharo');
					group: 'SQLite3' with: #(#'SSW ReStore SQLite3');
					group: 'P3 PostgreSQL' with: #(#'SSW ReStore P3');
					group: 'UDBC SQLite' with: #(#'SSW ReStore UDBC SQLite');
					group: 'Examples' with: #(#'SSW ReStore Examples');
					group: 'all' with: #('Tests' 'Examples' 'P3 PostgreSQL');
					group: 'default' with: #('Tests' 'Examples')]
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
BaselineOfReStore >> sqlite3: spec [

	spec
		baseline: 'Pharo-SQLite3'
		with: [
			spec
				repository: 'github://pharo-rdbms/Pharo-SQLite3/src'
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
