Extension { #name : #SSWDBDateAndTimeWithResolution }

{ #category : #'*SSW ReStore Main' }
SSWDBDateAndTimeWithResolution >> instanceFromDBValue: aValue in: aReStore [

	^aValue ifNotNil: [(self infoClass instanceFromDBValue: aValue in: aReStore) withResolution: self resolution]
]
