Extension { #name : 'DateAndTime' }

{ #category : '*SSW ReStore Main' }
DateAndTime class >> instanceFromDBValue: aValue in: anSSWReStore [

	"aValue may be nil, a DateAndTime, a Date or a Time depending on database supported types"
	^(aValue isNil or: [aValue class == DateAndTime])
		ifTrue: [aValue]
		ifFalse: [anSSWReStore sqlDialect dateAndTimeFrom: aValue]
]
