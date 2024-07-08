Extension { #name : 'String' }

{ #category : '*SSW ReStore Querying' }
String >> asWildcard [

	^WildcardString new
		string: self;
		yourself

]
