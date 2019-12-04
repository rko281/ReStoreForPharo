Extension { #name : #Boolean }

{ #category : #'*SSW ReStore Main' }
Boolean class >> instanceFromDBValue: aValue in: anSSWReStore [

	^aValue == true or: [aValue = anSSWReStore sqlDialect trueObject]
]
