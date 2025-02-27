Extension { #name : 'Boolean' }

{ #category : '*SSW ReStore Main' }
Boolean class >> instanceFromDBValue: aValue in: anSSWReStore [

	"Handle numeric aliases - 0 for false; another value (usually 1) for true"

	"Check the obvious possibilities first for efficiency"
	aValue == true ifTrue: [^true].
	aValue == false ifTrue: [^false].

	^aValue isNil 
		ifTrue: [anSSWReStore sqlDialect nullBoolean]
		ifFalse: [aValue ~= 0]
]
