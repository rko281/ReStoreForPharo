Extension { #name : 'SSWDBReadStream' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBReadStream >> errorEndOfStream [

	"Pharo does not error"
	
	^nil
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBReadStream >> nextAvailable [

	^self atEnd ifFalse: [self next]
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBReadStream >> nextPut: anObject [

	self shouldNotImplement
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBReadStream >> on: aCollection [

	"Don't want reset here"

	collection := aCollection.
	readLimit := aCollection size.
	position := 0.
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBReadStream >> size [
	
	^readLimit
]
