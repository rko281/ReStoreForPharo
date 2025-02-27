Extension { #name : 'Magnitude' }

{ #category : '*SSW ReStore Main' }
Magnitude class >> instanceFromDBString: aString [

	^self readFrom: aString readStream
]

{ #category : '*SSW ReStore Main' }
Magnitude class >> instanceFromDBValue: aValue in: anSSWReStore [

	"aValue may be nil, an instance of the receiver, or a String"

	^(aValue isNil or: [aValue class = self])
		ifTrue: [aValue]
		ifFalse: [self instanceFromDBString: aValue]
]
