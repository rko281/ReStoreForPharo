Extension { #name : #ByteArray }

{ #category : #'*SSW ReStore Base Additions' }
ByteArray class >> maxSize: anInteger [

	^SSWDBByteArrayWithInfo new
		fieldSize: anInteger;
		yourself
]
