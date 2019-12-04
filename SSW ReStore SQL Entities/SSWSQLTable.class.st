"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLTable,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #comparing }
SSWSQLTable >> = anSSWSQLTable [

	^self == anSSWSQLTable or: [self name = anSSWSQLTable name]
]

{ #category : #displaying }
SSWSQLTable >> displayOn: aStream [

	aStream nextPutAll: self name
]

{ #category : #testing }
SSWSQLTable >> hasStaticConditions [

	"Return a Boolean indicating if the receiver table has any SSWSQLConditions which are always applied when SELECTing from the receiver table.
	Unlike conditions that may be derived from other fields these conditions do not vary from object to object - they are static for all reads from this table.
	
	Default - false. Subclasses returning true should implement staticConditions accordingly"
	
	^false
]

{ #category : #comparing }
SSWSQLTable >> hash [

	^self name hash
]

{ #category : #accessing }
SSWSQLTable >> name [

	"name stores the name of this table"
		
	^name

]

{ #category : #accessing }
SSWSQLTable >> name: aString [

	"name stores the name of this table"
	
	name := aString

]

{ #category : #displaying }
SSWSQLTable >> printOn: aStream [

	super printOn: aStream.
	aStream 
		nextPutAll: ' (';
		display: self;
		nextPut: $)
]

{ #category : #output }
SSWSQLTable >> writeSQLNameOn: aStream [

	aStream nextPutIdentifier: self name

]

{ #category : #output }
SSWSQLTable >> writeSQLOn: aStream [

	self writeSQLNameOn: aStream

]
