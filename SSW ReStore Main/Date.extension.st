Extension { #name : #Date }

{ #category : #'*SSW ReStore Main' }
Date class >> instanceFromDBValue: aValue in: anSSWReStore [

	"aValue may be some other object which can convert itself to a Date"
	
	^(aValue isNil or: [aValue class = Date])
		ifTrue: [aValue]
		ifFalse: [anSSWReStore sqlDialect dateFrom: aValue]
]
