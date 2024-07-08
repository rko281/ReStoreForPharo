Extension { #name : 'Class' }

{ #category : '*SSW ReStore Querying' }
Class >> isPersistentIn: anSSWReStore [

	^anSSWReStore isClassPersistent: self
]
