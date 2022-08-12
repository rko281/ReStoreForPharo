"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWMSAccess2013Dialect,
	#superclass : #SSWMSAccessDialect,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #constants }
SSWMSAccess2013Dialect class >> dbmsVersion [

	^'12.*'
]

{ #category : #constants }
SSWMSAccess2013Dialect >> maxAllocatedStatements [

	"Access 2013 gives an error about number of open tables around 340 allocated statements"

	"Leave some headroom"
	^300
]
