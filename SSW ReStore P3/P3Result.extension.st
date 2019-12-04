Extension { #name : #P3Result }

{ #category : #'*SSW ReStore P3' }
P3Result >> asSSWP3Result [

	^SSWP3Result basicNew results: results descriptions: descriptions data: data
]
