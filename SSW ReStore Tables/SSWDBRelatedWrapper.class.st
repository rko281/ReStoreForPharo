"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBRelatedWrapper',
	#superclass : 'SSWDBWrapper',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'defining' }
SSWDBRelatedWrapper >> defineAs: aSymbol in: aDBTable [

	"Define the wrapped object, making the resulting object related"
		
	^(self relatedObject defineAs: aSymbol in: aDBTable) 
		beRelated;
		yourself
]

{ #category : 'accessing' }
SSWDBRelatedWrapper >> relatedObject [

	^self object
]
