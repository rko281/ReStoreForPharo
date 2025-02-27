"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLTableQuery',
	#superclass : 'SSWSQLQuery',
	#instVars : [
		'tables'
	],
	#category : 'SSW ReStore SQL Queries',
	#package : 'SSW ReStore SQL Queries'
}

{ #category : 'instance creation' }
SSWSQLTableQuery class >> new [

	^super new
		tables: SSWSQLLeftJoinedTableCollection new;
		yourself
]

{ #category : 'adding/removing' }
SSWSQLTableQuery >> addTable: anSSWDBTable joinedWithField: anSSWDBField [

	"Return the table added"
	
	^self tables addAliasingDuplicates: anSSWDBTable joinedWithField: anSSWDBField
]

{ #category : 'accessing - derived' }
SSWSQLTableQuery >> table [

	"Return the single table used by this query"
	
	^self tables soleTable
]

{ #category : 'accessing - derived' }
SSWSQLTableQuery >> table: anSSWDBTable [

	"Set the single table used by this query. Also used to set the initial table in a series of tables 
	- subsequent tables should be added using addTable:joinWith:"
	
	self tables soleTable: anSSWDBTable
]

{ #category : 'accessing' }
SSWSQLTableQuery >> tables [

	"tables stores an SSWSQLJoinedTableCollection of SSWDBTable involved in the receiver query.
	If the receiver only needs/supports a single table, it should use table/table:"
	
	^tables
]

{ #category : 'accessing' }
SSWSQLTableQuery >> tables: anSSWSQLJoinedTableCollection [

	"tables stores an SSWSQLJoinedTableCollection of SSWDBTable involved in the receiver query.
	If the receiver only needs/supports a single table, it should use table/table:"
	
	tables := anSSWSQLJoinedTableCollection
]
