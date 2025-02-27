"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLTableComponent',
	#superclass : 'Object',
	#instVars : [
		'table'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLTableComponent class >> forTable: anSSWDBTable [

	^self new
		table: anSSWDBTable;
		yourself
]

{ #category : 'accessing' }
SSWSQLTableComponent >> table [

	"table stores the SQLTable to which the receiver belongs"
	
	^table
]

{ #category : 'accessing' }
SSWSQLTableComponent >> table: anSSWDBTable [

	"table stores the SQLTable to which the receiver belongs"
	
	table := anSSWDBTable
]
