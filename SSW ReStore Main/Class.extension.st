Extension { #name : #Class }

{ #category : #'*SSW ReStore Main' }
Class >> isValidForPersistence [

	"Classes are not persisted directly (e.g. via storeIn:), therefore consider them already persistent"
	
	^true
]

{ #category : #'*SSW ReStore Main' }
Class >> reStoreValue [

	^self name asString
]

{ #category : #'*SSW ReStore Main' }
Class >> writeSQLOn: aStream [

	self name asString printOn: aStream
]
