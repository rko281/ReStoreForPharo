Extension { #name : 'SSWDBDateAndTimeWithResolution' }

{ #category : '*SSW ReStore Main' }
SSWDBDateAndTimeWithResolution >> instanceFromDBValue: aValue in: aReStore [

	| dateAndTime |

	^aValue ifNotNil: 
		[dateAndTime := self infoClass instanceFromDBValue: aValue in: aReStore.
		self resolution isNil 
			ifTrue: [dateAndTime]
			ifFalse: [dateAndTime withResolution: self resolution]]
]
