Extension { #name : 'Character' }

{ #category : '*SSW ReStore SQL Entities' }
Character >> reStoreValue [

	"As far as SQL is concerned, a Character == a String"
	
	^String with: self
]
