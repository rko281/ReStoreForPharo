Extension { #name : 'P3Result' }

{ #category : '*SSW ReStore P3' }
P3Result >> asSSWP3ResultSet [

	^SSWP3ResultSet basicNew results: results descriptions: descriptions data: data
]
