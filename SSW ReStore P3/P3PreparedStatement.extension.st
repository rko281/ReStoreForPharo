Extension { #name : #P3PreparedStatement }

{ #category : #'*SSW ReStore P3' }
P3PreparedStatement >> asSSWP3Statement [

	^SSWP3Statement basicNew client: client name: name paramDescriptions: paramDescriptions fieldDescriptions: fieldDescriptions
]
