Extension { #name : #Boolean }

{ #category : #'*SSW ReStore Main' }
Boolean class >> instanceFromDBValue: aValue in: anSSWReStore [

	"Check the obvious possibilities first for efficiency"
	aValue == true ifTrue: [^true].
	aValue == false ifTrue: [^false].

	^aValue isNil 
		ifTrue: [anSSWReStore sqlDialect nullBoolean]
		ifFalse: [aValue = anSSWReStore sqlDialect trueObject]
]
