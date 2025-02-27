Extension { #name : 'Date' }

{ #category : '*SSW ReStore Main' }
Date class >> instanceFromDBString: aString [

	^self readFrom: aString readStream format: 'yyyy-MM-dd'
]
