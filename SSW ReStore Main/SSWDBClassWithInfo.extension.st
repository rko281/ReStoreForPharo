Extension { #name : #SSWDBClassWithInfo }

{ #category : #'*SSW ReStore Main' }
SSWDBClassWithInfo >> instanceFromDBValue: aValue in: aReStore [

	^self infoClass instanceFromDBValue: aValue in: aReStore
]
