"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'RequiredUndefinedObject',
	#superclass : 'Object',
	#classInstVars : [
		'soleInstance'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'accessing' }
RequiredUndefinedObject class >> soleInstance [

	soleInstance isNil ifTrue: [soleInstance := self basicNew].

	^soleInstance
]

{ #category : 'comparing' }
RequiredUndefinedObject >> = anObject [

	^anObject isNil
]

{ #category : 'comparing' }
RequiredUndefinedObject >> hash [

	^nil hash
]

{ #category : 'testing' }
RequiredUndefinedObject >> isRequiredForSimilarity [

	"This is the purpose of the receiver"
	^true
]

{ #category : 'testing' }
RequiredUndefinedObject >> isSQLNull [

	^true
]

{ #category : 'accessing' }
RequiredUndefinedObject >> orNilIfEmpty [

	^self
]

{ #category : 'printing' }
RequiredUndefinedObject >> printOn: aStream [

	aStream nextPutAll: 'nil (required)'
]

{ #category : 'accessing' }
RequiredUndefinedObject >> qualify: instances in: aReStore via: aCollection [

	^instances qualifyWith: [ :each | (each chainPerform: aCollection) = nil]
]

{ #category : 'accessing' }
RequiredUndefinedObject >> reStoreValue [

	^nil
]

{ #category : 'printing' }
RequiredUndefinedObject >> writeSQLOn: aStream forCondition: aSQLCondition [

	nil writeSQLOn: aStream forCondition: aSQLCondition
]
