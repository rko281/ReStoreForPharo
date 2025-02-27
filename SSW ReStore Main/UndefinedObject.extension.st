Extension { #name : 'UndefinedObject' }

{ #category : '*SSW ReStore Main' }
UndefinedObject >> _ensurePersistentIn: aReStore [

	"A no-op for nil"
]

{ #category : '*SSW ReStore Main' }
UndefinedObject >> storeIn: anSSWReStore [

	"Do nothing - cannot store an UndefinedObject"
]

{ #category : '*SSW ReStore Main' }
UndefinedObject >> unstore [

	"Do nothing - cannot store/unstore an UndefinedObject"
]
