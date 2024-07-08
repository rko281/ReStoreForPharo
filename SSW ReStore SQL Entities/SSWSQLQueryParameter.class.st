"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLQueryParameter',
	#superclass : 'Object',
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLQueryParameter class >> new [

	"The receiver should not have instances created"

	^self error: 'Do not create instances of this class'
]

{ #category : 'instance creation' }
SSWSQLQueryParameter class >> writeSQLOn: aStream [

	"The receiver exists purely to write the parameter placeholder character(s) (usually '?')"

	aStream nextPutParameterPlaceholder
]
