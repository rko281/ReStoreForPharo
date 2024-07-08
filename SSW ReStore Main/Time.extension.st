Extension { #name : 'Time' }

{ #category : '*SSW ReStore Main' }
Time class >> instanceFromDBValue: aValue in: anSSWReStore [

	"aValue may be some other object which can convert itself to a Time"
	
	^(aValue isNil or: [aValue class = Time])
		ifTrue: [aValue]
		ifFalse: [anSSWReStore sqlDialect timeFrom: aValue]
]
