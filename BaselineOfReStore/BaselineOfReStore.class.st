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
				self porpoise: spec.
				self sqlite3: spec.
				self p3: spec.
				self mySQL: spec.
				self odbc: spec.
				spec
					package: 'SSW ReStore Base Additions' with: [ spec requires: #('Porpoise') ];
					package: 'SSW ReStore SQL Entities' with: [ spec requires: #('SSW ReStore Base Additions') ];
					package: 'SSW ReStore SQL Queries' with: [ spec requires: #('SSW ReStore SQL Entities') ];
					package: 'SSW ReStore Tables' with: [ spec requires: #('SSW ReStore SQL Queries') ];
					package: 'SSW ReStore Collections' with: [ spec requires: #('SSW ReStore Tables') ];
					package: 'SSW ReStore Querying' with: [ spec requires: #('SSW ReStore Collections') ];
					package: 'SSW ReStore Main' with: [ spec requires: #('SSW ReStore Querying') ];
					package: 'SSW ReStore for Pharo' with: [ spec requires: #('SSW ReStore Main') ];
					package: 'SSW ReStore SQLite3' with: [ spec requires: #('SSW ReStore for Pharo' 'SQLite3') ];
					package: 'SSW ReStore Tests' with: [ spec requires: #('SSW ReStore SQLite3') ];
					package: 'SSW ReStore Tests-Pharo' with: [ spec requires: #('SSW ReStore Tests') ];
					package: 'SSW ReStore Examples' with: [ spec requires: #('SSW ReStore SQLite3') ];
					package: 'SSW ReStore P3' with: [ spec requires: #('SSW ReStore for Pharo' 'P3') ];
					package: 'SSW ReStore MySQL' with: [ spec requires: #('SSW ReStore for Pharo' 'MySQL') ] ;
					package: 'SSW ReStore ODBC' with: [ spec requires: #('SSW ReStore for Pharo' 'ODBC') ] .
				
				spec
					group: 'Tests' with: #(#'SSW ReStore Tests-Pharo');
					group: 'Pharo SQLite3' with: #(#'SSW ReStore SQLite3');
					group: 'P3 PostgreSQL' with: #(#'SSW ReStore P3');
					group: 'Pharo MySQL' with: #(#'SSW ReStore MySQL');
					group: 'Pharo ODBC' with: #(#'SSW ReStore ODBC');
					group: 'Examples' with: #(#'SSW ReStore Examples');
					group: 'all' with: #('Tests' 'Examples' 'P3 PostgreSQL' 'Pharo MySQL');
					group: 'default' with: #('Tests' 'Examples')]
]

{ #category : #baselines }
BaselineOfReStore >> mySQL: spec [

	spec
		baseline: 'MySQL'
		with: [
			spec
				repository: 'github://rko281/Pharo-MySQL:development'
		]
]

{ #category : #baselines }
BaselineOfReStore >> odbc: spec [

	spec
		baseline: 'ODBC'
		with: [
			spec
				repository: 'github://pharo-rdbms/Pharo-ODBC/src'
		]
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
BaselineOfReStore >> porpoise: spec [

	spec
		baseline: 'Porpoise'
		with: [
			spec
				repository: 'github://rko281/Porpoise';
				loads: 'core'
		]
]

{ #category : #baselines }
BaselineOfReStore >> sqlite3: spec [

	spec
		baseline: 'SQLite3'
		with: [
			spec
				repository: 'github://rko281/Pharo-SQLite3:development/src'
		]
]
