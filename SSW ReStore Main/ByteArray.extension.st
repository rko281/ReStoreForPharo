Extension { #name : #ByteArray }

{ #category : #'*SSW ReStore Main' }
ByteArray class >> instanceFromDBValue: aValue in: anSSWReStore [

	"ASSERT: aValue isNil OR aValue isKindOf: self"

	^aValue
]
